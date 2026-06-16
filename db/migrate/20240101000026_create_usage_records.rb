class CreateUsageRecords < ActiveRecord::Migration[8.0]
  def up
    execute <<-SQL
      CREATE TABLE usage_records (
        id uuid DEFAULT gen_random_uuid() NOT NULL,
        organization_id uuid NOT NULL,
        metric character varying NOT NULL,
        granularity character varying NOT NULL,
        bucket timestamp with time zone NOT NULL,
        count bigint NOT NULL DEFAULT 0,
        billable_count bigint NOT NULL DEFAULT 0,
        cost numeric(12,6) DEFAULT 0.0,
        metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
        deleted_at timestamp with time zone,
        created_at timestamp with time zone NOT NULL,
        updated_at timestamp with time zone NOT NULL,
        PRIMARY KEY (id, bucket)
      ) PARTITION BY RANGE (bucket);
    SQL

    execute <<-SQL
      CREATE TABLE usage_records_202401 PARTITION OF usage_records
        FOR VALUES FROM ('2024-01-01') TO ('2024-04-01');
    SQL
    execute <<-SQL
      CREATE TABLE usage_records_202404 PARTITION OF usage_records
        FOR VALUES FROM ('2024-04-01') TO ('2024-07-01');
    SQL
    execute <<-SQL
      CREATE TABLE usage_records_202407 PARTITION OF usage_records
        FOR VALUES FROM ('2024-07-01') TO ('2024-10-01');
    SQL
    execute <<-SQL
      CREATE TABLE usage_records_202410 PARTITION OF usage_records
        FOR VALUES FROM ('2024-10-01') TO ('2025-01-01');
    SQL

    add_index :usage_records, [:organization_id, :metric, :granularity, :bucket],
              unique: true, name: "idx_usage_records_unique_bucket"
    add_index :usage_records, [:organization_id, :granularity, :bucket]
    add_index :usage_records, :bucket
    add_index :usage_records, :metric
  end

  def down
    drop_table :usage_records
  end
end
