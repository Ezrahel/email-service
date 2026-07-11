module Alerting
  class AlertEngine < ApplicationService
    COOLDOWN_PERIODS = {
      provider_outage: 5.minutes,
      delivery_degradation: 5.minutes,
      high_bounce_rate: 15.minutes,
      queue_backlog: 5.minutes,
      cost_anomaly: 1.hour,
      quota_exceeded: 1.hour
    }.freeze

    def initialize(organization:)
      @organization = organization
    end

    def call
      alerts = evaluate_rules
      filtered = deduplicate(alerts)
      filtered.each { |alert| dispatch(alert) }
      { evaluated: alerts.size, dispatched: filtered.size, alerts: filtered }
    end

    private

    def evaluate_rules
      [
        check_provider_outage,
        check_delivery_degradation,
        check_high_bounce_rate,
        check_queue_backlog,
        check_cost_anomaly,
        check_quota_exceeded
      ].compact
    end

    def check_provider_outage
      ProviderConfig.where(organization_id: @organization.id, enabled: true).find_each.map do |config|
        recent = ProviderAttempt
          .where(provider: config.provider)
          .where("created_at > ?", 5.minutes.ago)

        total = recent.count
        next unless total > 20

        failed = recent.where(status: "failed").count
        fail_rate = failed.to_f / total

        if fail_rate > 0.5
          {
            type: :provider_outage,
            severity: :critical,
            provider: config.provider,
            message: "Provider #{config.provider} outage detected: #{fail_rate * 100}% failure rate in last 5 minutes",
            value: (fail_rate * 100).round(2),
            threshold: 50
          }
        end
      end.compact
    end

    def check_delivery_degradation
      recent = @organization.email_messages.where("created_at > ?", 5.minutes.ago)
      total = recent.count
      return nil if total < 10

      failed = recent.where(status: "failed").count
      fail_rate = failed.to_f / total

      if fail_rate > 0.15
        {
          type: :delivery_degradation,
          severity: :critical,
          message: "Delivery degradation: #{fail_rate * 100}% failure rate in last 5 minutes",
          value: (fail_rate * 100).round(2),
          threshold: 15
        }
      end
    end

    def check_high_bounce_rate
      recent = @organization.email_messages.where("created_at > ?", 30.minutes.ago)
      total = recent.count
      return nil if total < 20

      bounced = recent.where(status: "bounced").count
      bounce_rate = bounced.to_f / total

      if bounce_rate > 0.05
        {
          type: :high_bounce_rate,
          severity: :warning,
          message: "High bounce rate: #{bounce_rate * 100}% in last 30 minutes",
          value: (bounce_rate * 100).round(2),
          threshold: 5
        }
      end
    end

    def check_queue_backlog
      return nil unless defined?(Sidekiq::Stats)

      stats = Sidekiq::Stats.new
      queue_depth = stats.queues.sum { |_, v| v || 0 }

      if queue_depth > 20_000
        {
          type: :queue_backlog,
          severity: :warning,
          message: "Queue backlog: #{queue_depth} jobs waiting",
          value: queue_depth,
          threshold: 20_000
        }
      end
    rescue StandardError
      nil
    end

    def check_cost_anomaly
      today = @organization.usage_records
        .for_metric("emails_sent")
        .where(bucket: Time.current.beginning_of_day..Time.current)
        .sum(:cost)

      yesterday = @organization.usage_records
        .for_metric("emails_sent")
        .where(bucket: 1.day.ago.beginning_of_day..1.day.ago.end_of_day)
        .sum(:cost)

      return nil if yesterday.zero?

      increase_pct = ((today - yesterday).to_f / yesterday * 100).round(2)
      if increase_pct > 200
        {
          type: :cost_anomaly,
          severity: :warning,
          message: "Cost anomaly: #{increase_pct}% increase vs yesterday",
          value: increase_pct,
          threshold: 200,
          today_cost: today,
          yesterday_cost: yesterday
        }
      end
    end

    def check_quota_exceeded
      monthly = @organization.email_messages
        .where("created_at > ?", Time.current.beginning_of_month)
        .count

      plan_limit = @organization.monthly_email_quota || 10_000

      if monthly >= plan_limit
        {
          type: :quota_exceeded,
          severity: :critical,
          message: "Monthly quota exceeded: #{monthly} / #{plan_limit}",
          value: monthly,
          threshold: plan_limit
        }
      end
    end

    def deduplicate(alerts)
      now = Time.current
      alerts.select do |alert|
        key = cache_key(alert)
        last_sent = Rails.cache.read(key)
        cooldown = COOLDOWN_PERIODS[alert[:type]] || 5.minutes

        if last_sent.nil? || (now - Time.parse(last_sent)) > cooldown
          Rails.cache.write(key, now.iso8601, expires_in: cooldown + 60)
          true
        else
          false
        end
      end
    end

    def cache_key(alert)
      "alert:#{@organization.id}:#{alert[:type]}:#{alert[:provider] || 'global'}"
    end

    def dispatch(alert)
      notify_slack(alert) if ENV["SLACK_WEBHOOK_URL"].present?
      notify_email(alert) if @organization.billing_email.present?
      create_alert_event(alert)
    end

    def notify_slack(alert)
      Notifications::SlackNotifier.call(alert: alert, organization: @organization)
    rescue StandardError => e
      Rails.logger.warn "Slack notification failed: #{e.message}"
    end

    def notify_email(alert)
      Notifications::EmailNotifier.call(alert: alert, organization: @organization)
    rescue StandardError => e
      Rails.logger.warn "Email notification failed: #{e.message}"
    end

    def create_alert_event(alert)
      EventLog.record!(
        event_type: "alert.#{alert[:type]}",
        organization: @organization,
        source: "alert_engine",
        payload: alert.except(:type, :severity).merge(alert_type: alert[:type], severity: alert[:severity])
      )
    rescue StandardError => e
      Rails.logger.warn "Failed to record alert event: #{e.message}"
    end
  end
end
