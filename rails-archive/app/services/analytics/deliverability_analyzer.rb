module Analytics
  class DeliverabilityAnalyzer < ApplicationService
    def initialize(organization:, since: 30.days.ago, until_time: Time.current)
      @organization = organization
      @since = since
      @until = until_time
    end

    def call
      {
        overview: compute_overview,
        by_provider: compute_by_provider,
        by_domain: compute_by_domain,
        trend: compute_trend,
        ip_reputation: compute_ip_reputation,
        recommendations: generate_recommendations
      }
    end

    private

    def compute_overview
      messages = base_scope

      {
        total_sent: messages.count,
        delivered: status_count(messages, "delivered"),
        failed: status_count(messages, "failed"),
        bounced: status_count(messages, "bounced"),
        opened: messages.joins(:delivery).where(deliveries: { open_count: 1.. }).count,
        clicked: messages.joins(:delivery).where(deliveries: { click_count: 1.. }).count,
        complained: messages.joins(:delivery).where.not(deliveries: { complaint_at: nil }).count,
        delivery_rate: rate(status_count(messages, "delivered"), messages.count),
        open_rate: rate(
          messages.joins(:delivery).where(deliveries: { open_count: 1.. }).count,
          status_count(messages, "delivered")
        ),
        bounce_rate: rate(status_count(messages, "bounced"), messages.count),
        complaint_rate: rate(
          messages.joins(:delivery).where.not(deliveries: { complaint_at: nil }).count,
          messages.count
        )
      }
    end

    def compute_by_provider
      base_scope
        .joins(delivery: :provider_attempts)
        .where(provider_attempts: { created_at: @since..@until })
        .group("provider_attempts.provider")
        .select(
          "provider_attempts.provider AS provider",
          "COUNT(*) AS total",
          "COUNT(*) FILTER (WHERE email_messages.status = 'delivered') AS delivered",
          "COUNT(*) FILTER (WHERE email_messages.status = 'failed') AS failed",
          "COUNT(*) FILTER (WHERE email_messages.status = 'bounced') AS bounced",
          "AVG(provider_attempts.duration_ms)::numeric(10,2) AS avg_latency_ms"
        )
        .order("total DESC")
        .map do |r|
          {
            provider: r.provider,
            total: r.total.to_i,
            delivered: r.delivered.to_i,
            failed: r.failed.to_i,
            bounced: r.bounced.to_i,
            delivery_rate: rate(r.delivered.to_i, r.total.to_i),
            avg_latency_ms: r.avg_latency_ms
          }
        end
    end

    def compute_by_domain
      base_scope
        .joins(:domain)
        .group("domains.domain")
        .select(
          "domains.domain",
          "COUNT(*) AS total",
          "COUNT(*) FILTER (WHERE email_messages.status = 'delivered') AS delivered",
          "COUNT(*) FILTER (WHERE email_messages.status = 'bounced') AS bounced"
        )
        .order("total DESC")
        .map do |r|
          {
            domain: r.domain,
            total: r.total.to_i,
            delivered: r.delivered.to_i,
            bounced: r.bounced.to_i,
            delivery_rate: rate(r.delivered.to_i, r.total.to_i),
            bounce_rate: rate(r.bounced.to_i, r.total.to_i)
          }
        end
    end

    def compute_trend
      base_scope
        .group("date_trunc('day', email_messages.created_at)")
        .select(
          "date_trunc('day', email_messages.created_at) AS day",
          "COUNT(*) AS total",
          "COUNT(*) FILTER (WHERE status = 'delivered') AS delivered",
          "COUNT(*) FILTER (WHERE status = 'failed') AS failed",
          "COUNT(*) FILTER (WHERE status = 'bounced') AS bounced"
        )
        .order("day ASC")
        .map do |r|
          {
            date: r.day,
            total: r.total.to_i,
            delivered: r.delivered.to_i,
            failed: r.failed.to_i,
            bounced: r.bounced.to_i
          }
        end
    end

    def compute_ip_reputation
      base_scope
        .joins(delivery: :provider_attempts)
        .where.not(provider_attempts: { ip_address: nil })
        .group("provider_attempts.ip_address")
        .select(
          "provider_attempts.ip_address",
          "COUNT(*) AS total",
          "COUNT(*) FILTER (WHERE email_messages.status = 'delivered') AS delivered",
          "COUNT(*) FILTER (WHERE email_messages.status = 'bounced') AS bounced",
          "COUNT(*) FILTER (WHERE email_messages.status = 'failed') AS failed"
        )
        .order("total DESC")
        .limit(20)
        .map do |r|
          {
            ip: r.ip_address,
            total: r.total.to_i,
            delivered: r.delivered.to_i,
            bounced: r.bounced.to_i,
            delivery_rate: rate(r.delivered.to_i, r.total.to_i)
          }
        end
    end

    def generate_recommendations
      [].tap do |recs|
        overview = compute_overview
        recs << { type: "warning", message: "Bounce rate is high", metric: "bounce_rate", value: overview[:bounce_rate] } if overview[:bounce_rate] > 5
        recs << { type: "warning", message: "Complaint rate exceeds threshold", metric: "complaint_rate", value: overview[:complaint_rate] } if overview[:complaint_rate] > 0.1
        recs << { type: "info", message: "Open rate is healthy", metric: "open_rate", value: overview[:open_rate] } if overview[:open_rate] > 20
      end
    end

    def base_scope
      @organization.email_messages.where(created_at: @since..@until)
    end

    def status_count(scope, status)
      scope.where(status: status).count
    end

    def rate(part, total)
      return 0.0 if total.zero?
      (part.to_f / total * 100).round(2)
    end
  end
end
