module Billing
  class BillingAggregator < ApplicationService
    def initialize(organization:, billing_period_start: nil, billing_period_end: nil)
      @organization = organization
      @billing_period_start = billing_period_start || Time.current.beginning_of_month
      @billing_period_end = billing_period_end || Time.current.end_of_month
    end

    def call
      usage = aggregate_usage
      costs = calculate_costs(usage)
      generate_billing_event(usage, costs)

      {
        organization_id: @organization.id,
        period: { start: @billing_period_start, end: @billing_period_end },
        generated_at: Time.current,
        usage: usage,
        costs: costs,
        total_cost: costs.values.sum
      }
    end

    private

    def aggregate_usage
      records = @organization.usage_records
        .where(bucket: @billing_period_start..@billing_period_end)

      {
        emails_sent: records.for_metric("emails_sent").pick("SUM(count)::bigint") || 0,
        emails_delivered: records.for_metric("emails_delivered").pick("SUM(count)::bigint") || 0,
        emails_failed: records.for_metric("emails_failed").pick("SUM(count)::bigint") || 0,
        emails_bounced: records.for_metric("emails_bounced").pick("SUM(count)::bigint") || 0,
        api_calls: records.for_metric("api_calls").pick("SUM(count)::bigint") || 0,
        storage_bytes: records.for_metric("storage_bytes").pick("SUM(count)::bigint") || 0,
        bandwidth_bytes: records.for_metric("bandwidth_bytes").pick("SUM(count)::bigint") || 0,
        billable_emails: records.for_metric("emails_sent").pick("SUM(billable_count)::bigint") || 0,
        active_domains: @organization.domains.count,
        active_templates: @organization.templates.count
      }
    end

    def calculate_costs(usage)
      {
        email_cost: usage[:billable_emails] * 0.001,
        storage_cost: (usage[:storage_bytes].to_f / 1_073_741_824) * 0.023,
        bandwidth_cost: (usage[:bandwidth_bytes].to_f / 1_073_741_824) * 0.09,
        base_plan: base_plan_cost
      }
    end

    def base_plan_cost
      case @organization.plan
      when "free" then 0
      when "pro" then 29.99
      when "business" then 99.99
      when "enterprise" then 499.99
      else 0
      end
    end

    def generate_billing_event(usage, costs)
      EventLog.record!(
        event_type: "billing.period_summary",
        organization: @organization,
        source: "billing_aggregator",
        payload: {
          period_start: @billing_period_start,
          period_end: @billing_period_end,
          usage: usage,
          costs: costs,
          total_cost: costs.values.sum
        }
      )
    end
  end
end
