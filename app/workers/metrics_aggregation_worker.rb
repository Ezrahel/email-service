class MetricsAggregationWorker < ApplicationWorker
  sidekiq_options queue: :analytics, retry: 2, unique: :until_executed

  def perform
    aggregate_email_metrics!
    aggregate_usage_metrics!
    refresh_materialized_views!
  end

  private

  def aggregate_email_metrics!
    %w[hourly daily].each do |granularity|
      bucket_expr = granularity == "hourly" ? "date_trunc('hour', created_at)" : "date_trunc('day', created_at)"

      rows = EmailMessage
        .where("created_at > ?", 1.hour.ago)
        .group(bucket_expr, :organization_id)
        .select(
          "#{bucket_expr} AS bucket",
          :organization_id,
          "COUNT(*) AS total",
          "COUNT(*) FILTER (WHERE status = 'delivered') AS delivered",
          "COUNT(*) FILTER (WHERE status = 'failed') AS failed",
          "COUNT(*) FILTER (WHERE status = 'bounced') AS bounced"
        )

      rows.each do |row|
        upsert_aggregate(row, "email_volume", granularity)
      end
    end
  end

  def aggregate_usage_metrics!
    Organization.find_each do |org|
      monthly = org.email_messages
        .where("created_at > ?", Time.current.beginning_of_month)
        .count

      org.update_column(:monthly_email_sent, monthly)
    end
  end

  def refresh_materialized_views!
    ActiveRecord::Base.connection.execute("REFRESH MATERIALIZED VIEW CONCURRENTLY mv_daily_delivery_metrics")
    ActiveRecord::Base.connection.execute("REFRESH MATERIALIZED VIEW CONCURRENTLY mv_domain_reputation")
    ActiveRecord::Base.connection.execute("REFRESH MATERIALIZED VIEW CONCURRENTLY mv_hourly_send_volume")
  rescue ActiveRecord::StatementInvalid => e
    Rails.logger.warn "Materialized view refresh failed (may not exist yet): #{e.message}"
  end

  def upsert_aggregate(row, metric_name, granularity)
    aggregate = Aggregate.find_or_initialize_by(
      organization_id: row.organization_id,
      metric_name: metric_name,
      granularity: granularity,
      bucket: row.bucket
    )

    aggregate.update!(
      total_count: row.total,
      delivered_count: row.delivered,
      failed_count: row.failed,
      bounced_count: row.bounced,
      delivery_rate: row.total > 0 ? (row.delivered.to_f / row.total * 100).round(4) : 0
    )
  rescue ActiveRecord::RecordNotUnique
    retry
  end
end
