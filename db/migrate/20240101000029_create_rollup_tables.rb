class CreateRollupTables < ActiveRecord::Migration[8.0]
  def up
    # ── Minute-level rollup (1m) ──────────────────────────────────
    execute <<-SQL
      CREATE TABLE rollup_1m (
        id uuid DEFAULT gen_random_uuid() NOT NULL,
        organization_id uuid NOT NULL,
        metric character varying NOT NULL,
        bucket timestamp with time zone NOT NULL,
        count bigint NOT NULL DEFAULT 0,
        error_count bigint NOT NULL DEFAULT 0,
        latency_avg numeric(10,2),
        latency_p50 numeric(10,2),
        latency_p90 numeric(10,2),
        latency_p99 numeric(10,2),
        created_at timestamp with time zone NOT NULL,
        updated_at timestamp with time zone NOT NULL,
        PRIMARY KEY (id, bucket)
      ) PARTITION BY RANGE (bucket);
    SQL

    # ── 5-minute rollup ───────────────────────────────────────────
    execute <<-SQL
      CREATE TABLE rollup_5m (
        id uuid DEFAULT gen_random_uuid() NOT NULL,
        organization_id uuid NOT NULL,
        metric character varying NOT NULL,
        bucket timestamp with time zone NOT NULL,
        count bigint NOT NULL DEFAULT 0,
        error_count bigint NOT NULL DEFAULT 0,
        latency_avg numeric(10,2),
        latency_p50 numeric(10,2),
        latency_p90 numeric(10,2),
        latency_p99 numeric(10,2),
        created_at timestamp with time zone NOT NULL,
        updated_at timestamp with time zone NOT NULL,
        PRIMARY KEY (id, bucket)
      ) PARTITION BY RANGE (bucket);
    SQL

    # ── Daily domain metrics rollup ───────────────────────────────
    execute <<-SQL
      CREATE TABLE rollup_daily_domain (
        id uuid DEFAULT gen_random_uuid() NOT NULL,
        organization_id uuid NOT NULL,
        domain_id uuid,
        date date NOT NULL,
        total_sent integer NOT NULL DEFAULT 0,
        delivered integer NOT NULL DEFAULT 0,
        bounced integer NOT NULL DEFAULT 0,
        complained integer NOT NULL DEFAULT 0,
        opened integer NOT NULL DEFAULT 0,
        clicked integer NOT NULL DEFAULT 0,
        PRIMARY KEY (id, date)
      ) PARTITION BY RANGE (date);
    SQL

    # ── Provider cost tracking table ──────────────────────────────
    execute <<-SQL
      CREATE TABLE provider_costs (
        id uuid DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY,
        organization_id uuid NOT NULL,
        provider character varying NOT NULL,
        date date NOT NULL,
        emails_sent integer NOT NULL DEFAULT 0,
        cost_cents integer NOT NULL DEFAULT 0,
        currency character varying DEFAULT 'USD',
        created_at timestamp with time zone NOT NULL,
        updated_at timestamp with time zone NOT NULL,
        UNIQUE(organization_id, provider, date)
      );
    SQL

    # ── Retention policies table ──────────────────────────────────
    execute <<-SQL
      CREATE TABLE retention_policies (
        id uuid DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY,
        organization_id uuid,
        table_name character varying NOT NULL,
        retention_days integer NOT NULL DEFAULT 90,
        enabled boolean DEFAULT true,
        created_at timestamp with time zone NOT NULL,
        updated_at timestamp with time zone NOT NULL
      );
    SQL

    # ── Initial partitions for rollup tables ──────────────────────
    %w[rollup_1m rollup_5m].each do |table|
      %w[2024_Q1 2024_Q2 2024_Q3 2024_Q4 2025_Q1 2025_Q2].each do |name|
        year, quarter = name.split("_")
        year = year.to_i
        quarter = quarter.sub("Q", "").to_i
        start_month = (quarter - 1) * 3 + 1
        start_date = Date.new(year, start_month, 1)
        end_date = start_date >> 3
        execute "CREATE TABLE IF NOT EXISTS #{table}_#{name} PARTITION OF #{table} FOR VALUES FROM ('#{start_date}') TO ('#{end_date}');"
      end
    end

    %w[2024 2025 2026].each do |year|
      y = year.to_i
      execute "CREATE TABLE IF NOT EXISTS rollup_daily_domain_#{year} PARTITION OF rollup_daily_domain FOR VALUES FROM ('#{year}-01-01') TO ('#{y + 1}-01-01');"
    end

    create_default_retention_policies
  end

  def down
    %w[rollup_1m rollup_5m rollup_daily_domain provider_costs retention_policies].each do |table|
      drop_table table, if_exists: true, force: :cascade
    end
  end

  private

  def create_default_retention_policies
    now = Time.current.iso8601
    execute <<-SQL
      INSERT INTO retention_policies (table_name, retention_days, enabled, created_at, updated_at)
      VALUES
        ('event_logs', 30, true, '#{now}', '#{now}'),
        ('provider_attempts', 90, true, '#{now}', '#{now}'),
        ('webhook_deliveries', 30, true, '#{now}', '#{now}'),
        ('audit_logs', 365, true, '#{now}', '#{now}'),
        ('delivery_events', 90, true, '#{now}', '#{now}'),
        ('rollup_1m', 7, true, '#{now}', '#{now}'),
        ('rollup_5m', 30, true, '#{now}', '#{now}');
    SQL
  end
end
