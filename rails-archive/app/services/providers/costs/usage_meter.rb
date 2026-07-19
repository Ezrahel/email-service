module Providers
  module Costs
    class UsageMeter
      class << self
        def record_send(organization_id:, provider_type:, quantity: 1, metadata: {})
          today = Date.current

          UsageRecord.create!(
            organization_id: organization_id,
            record_type: "email_send",
            record_date: today,
            quantity: quantity,
            provider: provider_type,
            metadata: metadata
          )
        rescue ActiveRecord::RecordInvalid => e
          Rails.logger.error "Usage recording failed: #{e.message}"
        end

        def daily_count(organization_id, date = Date.current)
          UsageRecord.where(
            organization_id: organization_id,
            record_type: "email_send",
            record_date: date
          ).sum(:quantity)
        end

        def monthly_count(organization_id, date = Date.current)
          UsageRecord.where(
            organization_id: organization_id,
            record_type: "email_send",
            record_date: date.beginning_of_month..date.end_of_month
          ).sum(:quantity)
        end

        def provider_breakdown(organization_id, date = Date.current)
          UsageRecord.where(
            organization_id: organization_id,
            record_type: "email_send",
            record_date: date.beginning_of_month..date.end_of_month
          )
            .group(:provider)
            .sum(:quantity)
        end

        def usage_history(organization_id, limit: 30)
          UsageRecord.where(
            organization_id: organization_id,
            record_type: "email_send"
          )
            .where("record_date > ?", limit.days.ago)
            .group(:record_date)
            .order(record_date: :desc)
            .sum(:quantity)
        end
      end
    end
  end
end
