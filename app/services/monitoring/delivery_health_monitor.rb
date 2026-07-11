module Monitoring
  class DeliveryHealthMonitor < ApplicationService
    def initialize(organization: nil, since: 1.hour.ago)
      @organization = organization
      @since = since
    end

    def call
      orgs = @organization ? [@organization] : Organization.all
      results = orgs.map { |org| check_organization(org) }

      {
        timestamp: Time.current.iso8601,
        organizations: results,
        global: global_summary(results)
      }
    end

    private

    def check_organization(org)
      recent = org.email_messages.where("created_at > ?", @since)

      {
        organization_id: org.id,
        organization_name: org.name,
        total_sent: recent.count,
        delivered: recent.where(status: "delivered").count,
        failed: recent.where(status: "failed").count,
        bounced: recent.where(status: "bounced").count,
        delivery_rate: rate(recent.where(status: "delivered").count, recent.count),
        failure_rate: rate(recent.where(status: "failed").count, recent.count),
        bounce_rate: rate(recent.where(status: "bounced").count, recent.count),
        avg_latency_ms: avg_latency(org),
        provider_health: provider_health(org),
        status: determine_status(recent)
      }
    end

    def determine_status(recent)
      total = recent.count
      return "idle" if total.zero?

      failed_rate = recent.where(status: "failed").count.to_f / total
      bounce_rate = recent.where(status: "bounced").count.to_f / total

      if failed_rate > 0.10 || bounce_rate > 0.05
        "degraded"
      elsif failed_rate > 0.05 || bounce_rate > 0.02
        "warning"
      else
        "healthy"
      end
    end

    def avg_latency(org)
      Delivery.joins(:email_message)
        .where(email_messages: { organization_id: org.id })
        .where("last_attempt_at > ?", @since)
        .where.not(last_attempt_duration_ms: nil)
        .average(:last_attempt_duration_ms)&.round(2) || 0
    end

    def provider_health(org)
      ProviderConfig.where(organization_id: org.id).map do |config|
        recent_attempts = ProviderAttempt
          .where(provider: config.provider_type)
          .where("created_at > ?", @since)

        total = recent_attempts.count
        failed = recent_attempts.where(status: "failed").count

        {
          provider: config.provider_type,
          enabled: config.enabled?,
          attempts: total,
          failures: failed,
          success_rate: total > 0 ? ((total - failed).to_f / total * 100).round(2) : 100.0,
          status: failed > total * 0.2 ? "unhealthy" : "healthy"
        }
      end
    end

    def global_summary(results)
      total_sent = results.sum { |r| r[:total_sent] }
      total_delivered = results.sum { |r| r[:delivered] }

      {
        total_sent: total_sent,
        total_delivered: total_delivered,
        global_delivery_rate: rate(total_delivered, total_sent),
        degraded_orgs: results.count { |r| r[:status] == "degraded" },
        healthy_orgs: results.count { |r| r[:status] == "healthy" }
      }
    end

    def rate(part, total)
      return 0.0 if total.zero?
      (part.to_f / total * 100).round(2)
    end
  end
end
