class CreateMaterializedViews < ActiveRecord::Migration[8.0]
  def up
    # Daily delivery metrics per organization
    execute <<-SQL
      CREATE MATERIALIZED VIEW mv_daily_delivery_metrics AS
      SELECT
        em.organization_id,
        date_trunc('day', em.created_at) AS day,
        COUNT(*) AS total_sent,
        COUNT(*) FILTER (WHERE em.status = 'delivered') AS delivered,
        COUNT(*) FILTER (WHERE em.status = 'failed') AS failed,
        COUNT(*) FILTER (WHERE em.status = 'bounced') AS bounced,
        COUNT(*) FILTER (WHERE em.status = 'opened') AS opened,
        COUNT(*) FILTER (WHERE em.status = 'clicked') AS clicked,
        COUNT(*) FILTER (WHERE em.status = 'queued') AS queued,
        COUNT(*) FILTER (WHERE em.status = 'sending') AS sending,
        AVG(d.last_attempt_duration_ms) FILTER (WHERE d.last_attempt_duration_ms IS NOT NULL) AS avg_delivery_latency_ms,
        percentile_cont(0.50) WITHIN GROUP (ORDER BY d.last_attempt_duration_ms)
          FILTER (WHERE d.last_attempt_duration_ms IS NOT NULL) AS p50_latency_ms,
        percentile_cont(0.90) WITHIN GROUP (ORDER BY d.last_attempt_duration_ms)
          FILTER (WHERE d.last_attempt_duration_ms IS NOT NULL) AS p90_latency_ms,
        percentile_cont(0.99) WITHIN GROUP (ORDER BY d.last_attempt_duration_ms)
          FILTER (WHERE d.last_attempt_duration_ms IS NOT NULL) AS p99_latency_ms,
        now() AS refreshed_at
      FROM email_messages em
      LEFT JOIN deliveries d ON d.email_message_id = em.id
      GROUP BY em.organization_id, date_trunc('day', em.created_at)
      WITH NO DATA;
    SQL

    # Domain reputation summary
    execute <<-SQL
      CREATE MATERIALIZED VIEW mv_domain_reputation AS
      SELECT
        d.id AS domain_id,
        d.domain,
        d.organization_id,
        COUNT(de.id) AS total_deliveries,
        COUNT(*) FILTER (WHERE de.event_type = 'bounce') AS total_bounces,
        COUNT(*) FILTER (WHERE de.event_type = 'complaint') AS total_complaints,
        COUNT(*) FILTER (WHERE de.event_type = 'sent') AS total_sent,
        CASE
          WHEN COUNT(de.id) > 0
          THEN ROUND(
            (1.0 - COUNT(*) FILTER (WHERE de.event_type IN ('bounce', 'complaint'))::numeric / COUNT(de.id)::numeric) * 100,
            2
          )
          ELSE 100.00
        END AS reputation_score,
        max(de.event_timestamp) AS last_event_at,
        now() AS refreshed_at
      FROM domains d
      LEFT JOIN email_messages em ON em.domain_id = d.id
      LEFT JOIN delivery_events de ON de.email_message_id = em.id
      GROUP BY d.id, d.domain, d.organization_id
      WITH NO DATA;
    SQL

    # Hourly send volume (for rate limit dashboards)
    execute <<-SQL
      CREATE MATERIALIZED VIEW mv_hourly_send_volume AS
      SELECT
        organization_id,
        date_trunc('hour', created_at) AS hour,
        COUNT(*) AS volume,
        COUNT(*) FILTER (WHERE status = 'failed') AS failures,
        now() AS refreshed_at
      FROM email_messages
      WHERE created_at > now() - interval '7 days'
      GROUP BY organization_id, date_trunc('hour', created_at)
      WITH NO DATA;
    SQL

    # Unique indexes on materialized views for fast refreshes
    execute <<-SQL
      CREATE UNIQUE INDEX idx_mv_daily_delivery_metrics_unique
        ON mv_daily_delivery_metrics (organization_id, day);
    SQL
    execute <<-SQL
      CREATE UNIQUE INDEX idx_mv_domain_reputation_unique
        ON mv_domain_reputation (domain_id);
    SQL
    execute <<-SQL
      CREATE UNIQUE INDEX idx_mv_hourly_send_volume_unique
        ON mv_hourly_send_volume (organization_id, hour);
    SQL
  end

  def down
    execute "DROP MATERIALIZED VIEW IF EXISTS mv_daily_delivery_metrics"
    execute "DROP MATERIALIZED VIEW IF EXISTS mv_domain_reputation"
    execute "DROP MATERIALIZED VIEW IF EXISTS mv_hourly_send_volume"
  end
end
