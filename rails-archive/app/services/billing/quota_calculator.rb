module Billing
  class QuotaCalculator < ApplicationService
    def initialize(organization:)
      @organization = organization
    end

    def call
      monthly_limit = @organization.monthly_email_quota || 10_000
      monthly_sent = current_monthly_sent
      usage_pct = monthly_limit > 0 ? (monthly_sent.to_f / monthly_limit * 100).round(2) : 0

      {
        plan: @organization.plan || "free",
        limits: {
          monthly_emails: monthly_limit,
          api_rate_per_second: @organization.metadata&.dig("api_rate_limit") || 10,
          storage_bytes: @organization.metadata&.dig("storage_limit_bytes") || 1_073_741_824
        },
        current_usage: {
          monthly_emails_sent: monthly_sent,
          api_calls_this_month: current_api_calls,
          storage_used_bytes: current_storage_bytes
        },
        percentages: {
          email_usage: usage_pct,
        storage_usage: storage_pct
      },
      remaining: {
        emails: [monthly_limit - monthly_sent, 0].max,
        storage: [(@organization.metadata&.dig("storage_limit_bytes") || 1_073_741_824) - current_storage_bytes, 0].max
        }
      }
    end

    private

    def current_monthly_sent
      @organization.email_messages
        .where("created_at > ?", Time.current.beginning_of_month)
        .count
    end

    def current_api_calls
      @organization.usage_records
        .for_metric("api_calls")
        .where("bucket >= ?", Time.current.beginning_of_month)
        .sum(:count)
    end

    def current_storage_bytes
      @organization.attachments.sum(:byte_size)
    end

    def storage_pct
      limit = @organization.metadata&.dig("storage_limit_bytes") || 1_073_741_824
      return 0 if limit.zero?
      (current_storage_bytes.to_f / limit * 100).round(2)
    end
  end
end
