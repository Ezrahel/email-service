module Dashboard
  class Alerts < ApplicationService
    def initialize(organization:, since:, until_time:)
      @organization = organization
      @since = since
      @until = until_time
    end

    def call
      alerts = []

      alerts << check_failure_rate
      alerts << check_bounce_rate
      alerts << check_queue_backlog
      alerts << check_provider_health
      alerts << check_delivery_latency
      alerts << check_quota_usage

      {
        period: { since: @since, until: @until },
        total_alerts: alerts.compact.size,
        alerts: alerts.compact.sort_by { |a| a[:severity] }
      }
    end

    private

    def check_failure_rate
      recent = @organization.email_messages
        .where(created_at: @since..@until)

      total = recent.count
      return nil if total < 10

      failed = recent.where(status: "failed").count
      rate = (failed.to_f / total * 100).round(2)

      if rate > 10
        { type: "high_failure_rate", severity: "critical", message: "Failure rate at #{rate}%", value: rate, threshold: 10 }
      elsif rate > 5
        { type: "high_failure_rate", severity: "warning", message: "Failure rate at #{rate}%", value: rate, threshold: 5 }
      end
    end

    def check_bounce_rate
      recent = @organization.email_messages
        .where(created_at: @since..@until)

      total = recent.count
      return nil if total < 10

      bounced = recent.where(status: "bounced").count
      rate = (bounced.to_f / total * 100).round(2)

      if rate > 5
        { type: "high_bounce_rate", severity: "warning", message: "Bounce rate at #{rate}%", value: rate, threshold: 5 }
      end
    end

    def check_queue_backlog
      begin
        stats = Sidekiq::Stats.new
        queue_depth = stats.queues.sum { |_, v| v || 0 }

        if queue_depth > 10_000
          { type: "queue_backlog", severity: "warning", message: "Queue backlog of #{queue_depth} jobs", value: queue_depth, threshold: 10_000 }
        end
      rescue StandardError
        nil
      end
    end

    def check_provider_health
      ProviderConfig.where(organization_id: @organization.id).find_each.map do |config|
        hourly_failures = ProviderAttempt
          .where(provider: config.provider)
          .where("created_at > ?", 1.hour.ago)
          .where(status: "failed")
          .count

        if hourly_failures > 100
          { type: "provider_degradation", severity: "critical", message: "#{config.provider}: #{hourly_failures} failures in last hour", value: hourly_failures, threshold: 100, provider: config.provider }
        elsif hourly_failures > 50
          { type: "provider_degradation", severity: "warning", message: "#{config.provider}: #{hourly_failures} failures in last hour", value: hourly_failures, threshold: 50, provider: config.provider }
        end
      end.compact
    end

    def check_delivery_latency
      avg_latency = Delivery.joins(:email_message)
        .where(email_messages: { organization_id: @organization.id })
        .where("last_attempt_at > ?", 1.hour.ago)
        .where.not(last_attempt_duration_ms: nil)
        .average(:last_attempt_duration_ms)

      if avg_latency && avg_latency > 30_000
        { type: "high_latency", severity: "warning", message: "Average delivery latency at #{avg_latency.round(0)}ms", value: avg_latency.round(0), threshold: 30_000 }
      end
    end

    def check_quota_usage
      monthly_sent = @organization.email_messages
        .where("created_at > ?", Time.current.beginning_of_month)
        .count

      plan_limit = @organization.monthly_email_quota || 10_000
      usage_pct = (monthly_sent.to_f / plan_limit * 100).round(1)

      if usage_pct > 90
        { type: "quota_usage", severity: "warning", message: "Monthly quota at #{usage_pct}% (#{monthly_sent}/#{plan_limit})", value: usage_pct, threshold: 90 }
      end
    end
  end
end
