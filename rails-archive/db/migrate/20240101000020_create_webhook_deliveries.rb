class CreateWebhookDeliveries < ActiveRecord::Migration[8.0]
  def up
    execute <<-SQL
      CREATE TABLE webhook_deliveries (
        id uuid DEFAULT gen_random_uuid() NOT NULL,
        webhook_id uuid NOT NULL,
        organization_id uuid NOT NULL,
        event_type character varying NOT NULL,
        event_id uuid NOT NULL,
        attempt integer NOT NULL DEFAULT 1,
        status character varying NOT NULL DEFAULT 'pending',
        http_status integer,
        duration_ms integer,
        request_body text,
        response_body text,
        error_message character varying,
        signature character varying,
        delivered_at timestamp with time zone,
        deleted_at timestamp with time zone,
        created_at timestamp with time zone NOT NULL,
        updated_at timestamp with time zone NOT NULL,
        PRIMARY KEY (id, created_at)
      ) PARTITION BY RANGE (created_at);
    SQL

    execute <<-SQL
      CREATE TABLE webhook_deliveries_202401 PARTITION OF webhook_deliveries
        FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');
    SQL
    execute <<-SQL
      CREATE TABLE webhook_deliveries_202402 PARTITION OF webhook_deliveries
        FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');
    SQL
    execute <<-SQL
      CREATE TABLE webhook_deliveries_202403 PARTITION OF webhook_deliveries
        FOR VALUES FROM ('2024-03-01') TO ('2024-04-01');
    SQL
    execute <<-SQL
      CREATE TABLE webhook_deliveries_202404 PARTITION OF webhook_deliveries
        FOR VALUES FROM ('2024-04-01') TO ('2024-05-01');
    SQL
    execute <<-SQL
      CREATE TABLE webhook_deliveries_202405 PARTITION OF webhook_deliveries
        FOR VALUES FROM ('2024-05-01') TO ('2024-06-01');
    SQL
    execute <<-SQL
      CREATE TABLE webhook_deliveries_202406 PARTITION OF webhook_deliveries
        FOR VALUES FROM ('2024-06-01') TO ('2024-07-01');
    SQL
    execute <<-SQL
      CREATE TABLE webhook_deliveries_202407 PARTITION OF webhook_deliveries
        FOR VALUES FROM ('2024-07-01') TO ('2024-08-01');
    SQL
    execute <<-SQL
      CREATE TABLE webhook_deliveries_202408 PARTITION OF webhook_deliveries
        FOR VALUES FROM ('2024-08-01') TO ('2024-09-01');
    SQL
    execute <<-SQL
      CREATE TABLE webhook_deliveries_202409 PARTITION OF webhook_deliveries
        FOR VALUES FROM ('2024-09-01') TO ('2024-10-01');
    SQL
    execute <<-SQL
      CREATE TABLE webhook_deliveries_202410 PARTITION OF webhook_deliveries
        FOR VALUES FROM ('2024-10-01') TO ('2024-11-01');
    SQL
    execute <<-SQL
      CREATE TABLE webhook_deliveries_202411 PARTITION OF webhook_deliveries
        FOR VALUES FROM ('2024-11-01') TO ('2024-12-01');
    SQL
    execute <<-SQL
      CREATE TABLE webhook_deliveries_202412 PARTITION OF webhook_deliveries
        FOR VALUES FROM ('2024-12-01') TO ('2025-01-01');
    SQL

    add_index :webhook_deliveries, :webhook_id
    add_index :webhook_deliveries, :organization_id
    add_index :webhook_deliveries, :status
    add_index :webhook_deliveries, :event_type
    add_index :webhook_deliveries, [:webhook_id, :event_id]
    add_index :webhook_deliveries, [:organization_id, :created_at]
    add_index :webhook_deliveries, :created_at
    add_index :webhook_deliveries, :deleted_at
  end

  def down
    drop_table :webhook_deliveries
  end
end
