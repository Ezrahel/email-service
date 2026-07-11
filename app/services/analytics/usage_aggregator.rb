module Analytics
  class UsageAggregator < ApplicationService
    METRICS = %w[
      emails_sent emails_delivered emails_failed emails_bounced
      api_calls storage_bytes bandwidth_bytes
    ].freeze

    def initialize(organization: nil, granularity: "daily", since: 30.days.ago, until_time: Time.current)
      @organization = organization
      @granularity = granularity
      @since = since
      @until = until_time
    end

    def call
      orgs = @organization ? [@organization] : Organization.all

      orgs.each do |org|
        aggregate_emails_sent(org)
        aggregate_api_calls(org)
        aggregate_storage(org)
      end

      { aggregated: true, granularity: @granularity, since: @since, until: @until }
    end

    private

    def aggregate_emails_sent(org)
      bucket_expr = "date_trunc('#{pg_trunc}', email_messages.created_at)"

      rows = org.email_messages
        .where(created_at: @since..@until)
        .group(bucket_expr)
        .select(
          "#{bucket_expr} AS bucket",
          "COUNT(*) AS total",
          "COUNT(*) FILTER (WHERE status = 'delivered') AS delivered",
          "COUNT(*) FILTER (WHERE status = 'failed') AS failed",
          "COUNT(*) FILTER (WHERE status = 'bounced') AS bounced",
          "SUM(LENGTH(COALESCE(html_body, '')) + LENGTH(COALESCE(text_body, ''))) AS bytes_sent"
        )

      rows.each do |r|
        upsert_usage(org, "emails_sent", r.bucket, r.total, r.total)
        upsert_usage(org, "emails_delivered", r.bucket, r.delivered, r.delivered)
        upsert_usage(org, "emails_failed", r.bucket, r.failed, r.failed)
        upsert_usage(org, "emails_bounced", r.bucket, r.bounced, r.bounced)

        if r.bytes_sent&.positive?
          upsert_usage(org, "bandwidth_bytes", r.bucket, r.bytes_sent, r.bytes_sent)
        end
      end
    end

    def aggregate_api_calls(org)
      bucket_expr = "date_trunc('#{pg_trunc}', created_at)"

      rows = org.usage_records
        .where(metric: "api_call", created_at: @since..@until)
        .group(bucket_expr)
        .select("#{bucket_expr} AS bucket", "SUM(count) AS total_calls")

      rows.each do |r|
        upsert_usage(org, "api_calls", r.bucket, r.total_calls, r.total_calls)
      end
    end

    def aggregate_storage(org)
      total_bytes = org.attachments
        .where(created_at: @since..@until)
        .sum(:byte_size)

      bucket = @since.beginning_of_day
      upsert_usage(org, "storage_bytes", bucket, total_bytes, total_bytes) if total_bytes.positive?
    end

    def upsert_usage(org, metric, bucket, count, billable)
      record = UsageRecord.find_or_initialize_by(
        organization: org,
        metric: metric,
        granularity: @granularity,
        bucket: bucket
      )
      record.count = count.to_i
      record.billable_count = billable.to_i
      record.save! if record.changed?
    rescue ActiveRecord::RecordNotUnique
      retry
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
