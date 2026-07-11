module Dashboard
  class Usage < ApplicationService
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
        by_metric: compute_by_metric
      }
    end

    private

    def compute_summary
      messages = @organization.email_messages.where(created_at: @since..@until)
      usage = @organization.usage_records.where(bucket: @since..@until)

      {
        total_sent: messages.count,
        total_delivered: messages.where(status: "delivered").count,
        total_failed: messages.where(status: "failed").count,
        total_bounced: messages.where(status: "bounced").count,
        total_api_calls: usage.for_metric("api_calls").sum(:count),
        total_storage_bytes: usage.for_metric("storage_bytes").sum(:count),
        estimated_cost: usage.sum(:cost)
      }
    end

    def compute_time_series
      bucket_expr = "date_trunc('#{pg_trunc}', bucket)"

      @organization.usage_records
        .where(bucket: @since..@until)
        .group(bucket_expr)
        .select(
          "#{bucket_expr} AS bucket",
          "SUM(count) AS total_usage",
          "SUM(billable_count) AS total_billable",
          "SUM(cost) AS total_cost"
        )
        .order("bucket ASC")
        .map do |r|
          {
            bucket: r.bucket,
            total_usage: r.total_usage.to_i,
            total_billable: r.total_billable.to_i,
            total_cost: r.total_cost.to_f
          }
        end
    end

    def compute_by_metric
      @organization.usage_records
        .where(bucket: @since..@until)
        .group(:metric)
        .select("metric", "SUM(count) AS total", "SUM(billable_count) AS billable", "SUM(cost) AS cost")
        .map do |r|
          {
            metric: r.metric,
            total: r.total.to_i,
            billable: r.billable.to_i,
            cost: r.cost.to_f
          }
        end
    end

    def pg_trunc
      case @granularity
      when "hourly" then "hour"
      when "daily" then "day"
      when "monthly" then "month"
      else "day"
      end
    end
  end
end
