module Providers
  module Costs
    class ProviderCostTracker
      COST_PER_EMAIL = {
        "ses" => 0.0001,
        "sendgrid" => 0.001,
        "mailgun" => 0.0008,
        "postmark" => 0.001,
        "smtp" => 0.0
      }.freeze

      class << self
        def estimate_cost(provider_type, quantity: 1)
          per_email = COST_PER_EMAIL[provider_type] || 0.001
          (per_email * quantity).round(6)
        end

        def track_delivery(organization_id:, provider_type:, quantity: 1)
          cost = estimate_cost(provider_type, quantity: quantity)

          UsageRecord.create!(
            organization_id: organization_id,
            record_type: "provider_cost",
            record_date: Date.current,
            quantity: quantity,
            provider: provider_type,
            metadata: { estimated_cost: cost, currency: "USD" }
          )

          cost
        rescue ActiveRecord::RecordInvalid => e
          0.0
        end

        def monthly_cost(organization_id)
          UsageRecord.where(
            organization_id: organization_id,
            record_type: "provider_cost",
            record_date: Date.current.beginning_of_month..Date.current.end_of_month
          ).sum("(metadata->>'estimated_cost')::numeric")
        end

        def provider_cost_breakdown(organization_id)
          UsageRecord.where(
            organization_id: organization_id,
            record_type: "provider_cost",
            record_date: Date.current.beginning_of_month..Date.current.end_of_month
          )
            .group(:provider)
            .sum("(metadata->>'estimated_cost')::numeric")
        end

        def update_cost_per_email(provider_type, cost)
          REDIS_POOL.with do |conn|
            conn.set("cost:per_email:#{provider_type}", cost)
          end
        end

        def custom_cost_per_email(provider_type)
          REDIS_POOL.with do |conn|
            val = conn.get("cost:per_email:#{provider_type}")
            val&.to_f || COST_PER_EMAIL[provider_type] || 0.001
          end
        end
      end
    end
  end
end
