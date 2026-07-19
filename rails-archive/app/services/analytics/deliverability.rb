module Analytics
  class Deliverability < ApplicationService
    def initialize(organization:, granularity:, since:, until:)
      @organization = organization
      @granularity = granularity
      @since = since
      @until = until
    end

    def call
      bucket_expr = case @granularity
      when "hourly" then "date_trunc('hour', email_messages.created_at)"
      when "daily" then "date_trunc('day', email_messages.created_at)"
      when "monthly" then "date_trunc('month', email_messages.created_at)"
      else "date_trunc('day', email_messages.created_at)"
      end

      rows = @organization.email_messages
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

      {
        granularity: @granularity,
        series: rows.map do |r|
          {
            bucket: r.bucket,
            total: r.total.to_i,
            delivered: r.delivered.to_i,
            failed: r.failed.to_i,
            bounced: r.bounced.to_i,
            delivery_rate: calculate_rate(r.delivered.to_i, r.total.to_i),
            bounce_rate: calculate_rate(r.bounced.to_i, r.total.to_i)
          }
        end
      }
    end

    private

    def calculate_rate(part, total)
      return 0.0 if total.zero?
      (part.to_f / total * 100).round(2)
    end
  end
end
