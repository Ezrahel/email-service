class CreateAggregates < ActiveRecord::Migration[8.0]
  def up
    execute <<-SQL
      CREATE TABLE aggregates (
        id uuid DEFAULT gen_random_uuid() NOT NULL,
        organization_id uuid NOT NULL,
        metric_name character varying NOT NULL,
        granularity character varying NOT NULL,
        bucket timestamp with time zone NOT NULL,
        total_count bigint NOT NULL DEFAULT 0,
        delivered_count bigint NOT NULL DEFAULT 0,
        failed_count bigint NOT NULL DEFAULT 0,
        bounced_count bigint NOT NULL DEFAULT 0,
        opened_count bigint NOT NULL DEFAULT 0,
        clicked_count bigint NOT NULL DEFAULT 0,
        complained_count bigint NOT NULL DEFAULT 0,
        queued_count bigint NOT NULL DEFAULT 0,
        delivery_rate numeric(5,4),
        open_rate numeric(5,4),
        click_rate numeric(5,4),
        bounce_rate numeric(5,4),
        complaint_rate numeric(5,4),
        avg_delivery_latency_ms numeric(10,2),
        p50_latency_ms numeric(10,2),
        p90_latency_ms numeric(10,2),
        p99_latency_ms numeric(10,2),
        created_at timestamp with time zone NOT NULL,
        updated_at timestamp with time zone NOT NULL,
        PRIMARY KEY (id, bucket)
      ) PARTITION BY RANGE (bucket);
    SQL

    execute <<-SQL
      CREATE TABLE aggregates_202401 PARTITION OF aggregates
        FOR VALUES FROM ('2024-01-01') TO ('2024-04-01');
    SQL
    execute <<-SQL
      CREATE TABLE aggregates_202404 PARTITION OF aggregates
        FOR VALUES FROM ('2024-04-01') TO ('2024-07-01');
    SQL
    execute <<-SQL
      CREATE TABLE aggregates_202407 PARTITION OF aggregates
        FOR VALUES FROM ('2024-07-01') TO ('2024-10-01');
    SQL
    execute <<-SQL
      CREATE TABLE aggregates_202410 PARTITION OF aggregates
        FOR VALUES FROM ('2024-10-01') TO ('2025-01-01');
    SQL

    add_index :aggregates, [:organization_id, :metric_name, :granularity, :bucket],
              unique: true, name: "idx_aggregates_unique_bucket"
    add_index :aggregates, [:organization_id, :granularity, :bucket]
    add_index :aggregates, :bucket
  end

  def down
    drop_table :aggregates
  end
end
