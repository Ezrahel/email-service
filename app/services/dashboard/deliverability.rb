module Dashboard
  class Deliverability < ApplicationService
    def initialize(organization:, since:, until_time:, granularity: "daily")
      @organization = organization
      @since = since
      @until = until_time
      @granularity = granularity
    end

    def call
      {
        granularity: @granularity,
        period: { since: @since, until: @until },
        summary: compute_summary,
        time_series: compute_time_series,
        by_provider: compute_by_provider,
        by_domain: compute_by_domain
      }
    end

    private

    def compute_summary
      messages = @organization.email_messages.where(created_at: @since..@until)

      {
        total_sent: messages.count,
        delivered: messages.where(status: "delivered").count,
        failed: messages.where(status: "failed").count,
        bounced: messages.where(status: "bounced").count,
        delivery_rate: rate(messages.where(status: "delivered").count, messages.count),
        bounce_rate: rate(messages.where(status: "bounced").count, messages.count),
        avg_latency_ms: Delivery.joins(:email_message)
          .where(email_messages: { organization_id: @organization.id })
          .where(last_attempt_at: @since..@until)
          .where.not(last_attempt_duration_ms: nil)
          .average(:last_attempt_duration_ms)&.round(2) || 0
      }
    end

    def compute_time_series
      bucket_expr = case @granularity
      when "hourly" then "date_trunc('hour', created_at)"
      when "daily" then "date_trunc('day', created_at)"
      when "monthly" then "date_trunc('month', created_at)"
      else "date_trunc('day', created_at)"
      end

      @organization.email_messages
        .where(created_at: @since..@until)
        .group(bucket_expr)
        .select(
          "#{bucket_expr} AS bucket",
          "COUNT(*) AS total",
          "COUNT(*) FILTER (WHERE status = 'delivered') AS delivered",
          "COUNT(*) FILTER (WHERE status = 'failed') AS failed",
          "COUNT(*) FILTER (WHERE status = 'bounced') AS bounced"
        )
        .order("bucket ASC")
        .map do |r|
          {
            bucket: r.bucket,
            total: r.total.to_i,
            delivered: r.delivered.to_i,
            failed: r.failed.to_i,
            bounced: r.bounced.to_i,
            delivery_rate: rate(r.delivered.to_i, r.total.to_i)
          }
        end
    end

    def compute_by_provider
      @organization.email_messages
        .joins(delivery: :provider_attempts)
        .where(provider_attempts: { created_at: @since..@until })
        .group("provider_attempts.provider")
        .select(
          "provider_attempts.provider",
          "COUNT(*) AS total",
          "COUNT(*) FILTER (WHERE email_messages.status = 'delivered') AS delivered",
          "COUNT(*) FILTER (WHERE email_messages.status = 'failed') AS failed",
          "COUNT(*) FILTER (WHERE email_messages.status = 'bounced') AS bounced",
          "AVG(provider_attempts.duration_ms)::numeric(10,2) AS avg_latency_ms"
        )
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
      @organization.email_messages
        .where(created_at: @since..@until)
        .joins(:domain)
        .group("domains.id", "domains.domain")
        .select(
          "domains.id",
          "domains.domain",
          "COUNT(*) AS total",
          "COUNT(*) FILTER (WHERE email_messages.status = 'delivered') AS delivered",
          "COUNT(*) FILTER (WHERE email_messages.status = 'bounced') AS bounced"
        )
        .map do |r|
          {
            domain_id: r.id,
            domain: r.domain,
            total: r.total.to_i,
            delivered: r.delivered.to_i,
            bounced: r.bounced.to_i,
            delivery_rate: rate(r.delivered.to_i, r.total.to_i)
          }
        end
    end

    def rate(part, total)
      return 0.0 if total.zero?
      (part.to_f / total * 100).round(2)
    end
  end
end
