class CreateDeliveries < ActiveRecord::Migration[8.0]
  def up
    execute <<-SQL
      CREATE TABLE deliveries (
        id uuid DEFAULT gen_random_uuid() NOT NULL,
        email_message_id uuid NOT NULL,
        organization_id uuid NOT NULL,
        provider_config_id uuid,
        status character varying NOT NULL DEFAULT 'pending',
        provider character varying NOT NULL,
        provider_message_id character varying,
        attempt_count integer NOT NULL DEFAULT 0,
        max_attempts integer NOT NULL DEFAULT 3,
        last_attempt_duration_ms integer,
        first_attempt_at timestamp with time zone,
        last_attempt_at timestamp with time zone,
        delivered_at timestamp with time zone,
        bounced_at timestamp with time zone,
        bounce_type character varying,
        bounce_classification character varying,
        complaint_at timestamp with time zone,
        opened_at timestamp with time zone,
        open_count integer NOT NULL DEFAULT 0,
        clicked_at timestamp with time zone,
        click_count integer NOT NULL DEFAULT 0,
        failure_reason character varying,
        failure_code character varying,
        provider_response jsonb NOT NULL DEFAULT '{}'::jsonb,
        provider_score numeric(5,2),
        deleted_at timestamp with time zone,
        created_at timestamp with time zone NOT NULL,
        updated_at timestamp with time zone NOT NULL,
        PRIMARY KEY (id, created_at)
      ) PARTITION BY RANGE (created_at);
    SQL

    execute <<-SQL
      CREATE TABLE deliveries_202401 PARTITION OF deliveries
        FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');
    SQL
    execute <<-SQL
      CREATE TABLE deliveries_202402 PARTITION OF deliveries
        FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');
    SQL
    execute <<-SQL
      CREATE TABLE deliveries_202403 PARTITION OF deliveries
        FOR VALUES FROM ('2024-03-01') TO ('2024-04-01');
    SQL
    execute <<-SQL
      CREATE TABLE deliveries_202404 PARTITION OF deliveries
        FOR VALUES FROM ('2024-04-01') TO ('2024-05-01');
    SQL
    execute <<-SQL
      CREATE TABLE deliveries_202405 PARTITION OF deliveries
        FOR VALUES FROM ('2024-05-01') TO ('2024-06-01');
    SQL
    execute <<-SQL
      CREATE TABLE deliveries_202406 PARTITION OF deliveries
        FOR VALUES FROM ('2024-06-01') TO ('2024-07-01');
    SQL
    execute <<-SQL
      CREATE TABLE deliveries_202407 PARTITION OF deliveries
        FOR VALUES FROM ('2024-07-01') TO ('2024-08-01');
    SQL
    execute <<-SQL
      CREATE TABLE deliveries_202408 PARTITION OF deliveries
        FOR VALUES FROM ('2024-08-01') TO ('2024-09-01');
    SQL
    execute <<-SQL
      CREATE TABLE deliveries_202409 PARTITION OF deliveries
        FOR VALUES FROM ('2024-09-01') TO ('2024-10-01');
    SQL
    execute <<-SQL
      CREATE TABLE deliveries_202410 PARTITION OF deliveries
        FOR VALUES FROM ('2024-10-01') TO ('2024-11-01');
    SQL
    execute <<-SQL
      CREATE TABLE deliveries_202411 PARTITION OF deliveries
        FOR VALUES FROM ('2024-11-01') TO ('2024-12-01');
    SQL
    execute <<-SQL
      CREATE TABLE deliveries_202412 PARTITION OF deliveries
        FOR VALUES FROM ('2024-12-01') TO ('2025-01-01');
    SQL

    add_index :deliveries, :email_message_id
    add_index :deliveries, :organization_id
    add_index :deliveries, :status
    add_index :deliveries, :provider
    add_index :deliveries, :provider_message_id, where: "provider_message_id IS NOT NULL"
    add_index :deliveries, [:organization_id, :status]
    add_index :deliveries, [:organization_id, :created_at]
    add_index :deliveries, :created_at
    add_index :deliveries, :deleted_at
  end

  def down
    drop_table :deliveries
  end
end
