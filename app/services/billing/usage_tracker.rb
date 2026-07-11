module Billing
  class UsageTracker < ApplicationService
    TRACKED_ACTIONS = {
      "email.sent" => { metric: "emails_sent", billable: true },
      "email.delivered" => { metric: "emails_delivered", billable: true },
      "email.failed" => { metric: "emails_failed", billable: false },
      "email.bounced" => { metric: "emails_bounced", billable: false },
      "api.call" => { metric: "api_calls", billable: false },
      "storage.used" => { metric: "storage_bytes", billable: true }
    }.freeze

    def initialize(organization:, action:, count: 1, metadata: {})
      @organization = organization
      @action = action
      @count = count
      @metadata = metadata
    end

    def call
      config = TRACKED_ACTIONS[@action]
      raise ArgumentError, "Unknown action: #{@action}" unless config

      track_usage!(
        metric: config[:metric],
        count: @count,
        billable: config[:billable]
      )

      update_monthly_counter!(config[:metric])
    end

    def self.track_send(organization:, count: 1)
      new(organization: organization, action: "email.sent", count: count).call
    end

    def self.track_delivery(organization:, count: 1)
      new(organization: organization, action: "email.delivered", count: count).call
    end

    def self.track_api_call(organization:)
      new(organization: organization, action: "api.call").call
    end

    private

    def track_usage!(metric:, count:, billable:)
      bucket = Time.current.beginning_of_hour

      record = UsageRecord.find_or_initialize_by(
        organization: @organization,
        metric: metric,
        granularity: "hourly",
        bucket: bucket
      )

      record.count = (record.count || 0) + count
      record.billable_count = (record.billable_count || 0) + (billable ? count : 0)
      record.cost = (record.cost || 0) + calculate_cost(metric, count, billable)

      record.save!
    rescue ActiveRecord::RecordNotUnique
      retry
    end

    def calculate_cost(metric, count, billable)
      return 0.0 unless billable

      case metric
      when "emails_sent", "emails_delivered"
        count * 0.001
      when "storage_bytes"
        (count.to_f / 1_073_741_824) * 0.023
      else
        0.0
      end
    end

    def update_monthly_counter!(metric)
      monthly_key = "monthly:#{@organization.id}:#{metric}:#{Time.current.strftime("%Y%m")}"
      Rails.cache.increment(monthly_key, @count, expires_in: 35.days)
    end
  end
end
