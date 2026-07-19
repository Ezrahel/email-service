class CreateEventLogs < ActiveRecord::Migration[8.0]
  def up
    execute <<-SQL
      CREATE TABLE event_logs (
        id uuid DEFAULT gen_random_uuid() NOT NULL,
        organization_id uuid NOT NULL,
        event_type character varying NOT NULL,
        resource_id uuid,
        resource_type character varying,
        payload jsonb NOT NULL DEFAULT '{}'::jsonb,
        metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
        source character varying NOT NULL,
        ip_address character varying,
        user_agent character varying,
        event_timestamp timestamp with time zone NOT NULL,
        processed_at timestamp with time zone,
        deleted_at timestamp with time zone,
        created_at timestamp with time zone NOT NULL,
        updated_at timestamp with time zone NOT NULL,
        PRIMARY KEY (id, created_at)
      ) PARTITION BY RANGE (created_at);
    SQL

    execute <<-SQL
      CREATE TABLE event_logs_202401 PARTITION OF event_logs
        FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');
    SQL
    execute <<-SQL
      CREATE TABLE event_logs_202402 PARTITION OF event_logs
        FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');
    SQL
    execute <<-SQL
      CREATE TABLE event_logs_202403 PARTITION OF event_logs
        FOR VALUES FROM ('2024-03-01') TO ('2024-04-01');
    SQL
    execute <<-SQL
      CREATE TABLE event_logs_202404 PARTITION OF event_logs
        FOR VALUES FROM ('2024-04-01') TO ('2024-05-01');
    SQL
    execute <<-SQL
      CREATE TABLE event_logs_202405 PARTITION OF event_logs
        FOR VALUES FROM ('2024-05-01') TO ('2024-06-01');
    SQL
    execute <<-SQL
      CREATE TABLE event_logs_202406 PARTITION OF event_logs
        FOR VALUES FROM ('2024-06-01') TO ('2024-07-01');
    SQL
    execute <<-SQL
      CREATE TABLE event_logs_202407 PARTITION OF event_logs
        FOR VALUES FROM ('2024-07-01') TO ('2024-08-01');
    SQL
    execute <<-SQL
      CREATE TABLE event_logs_202408 PARTITION OF event_logs
        FOR VALUES FROM ('2024-08-01') TO ('2024-09-01');
    SQL
    execute <<-SQL
      CREATE TABLE event_logs_202409 PARTITION OF event_logs
        FOR VALUES FROM ('2024-09-01') TO ('2024-10-01');
    SQL
    execute <<-SQL
      CREATE TABLE event_logs_202410 PARTITION OF event_logs
        FOR VALUES FROM ('2024-10-01') TO ('2024-11-01');
    SQL
    execute <<-SQL
      CREATE TABLE event_logs_202411 PARTITION OF event_logs
        FOR VALUES FROM ('2024-11-01') TO ('2024-12-01');
    SQL
    execute <<-SQL
      CREATE TABLE event_logs_202412 PARTITION OF event_logs
        FOR VALUES FROM ('2024-12-01') TO ('2025-01-01');
    SQL

    add_index :event_logs, :event_type
    add_index :event_logs, :event_timestamp
    add_index :event_logs, :processed_at, where: "processed_at IS NULL"
    add_index :event_logs, [:organization_id, :event_type, :event_timestamp]
    add_index :event_logs, [:organization_id, :event_timestamp]
    add_index :event_logs, [:resource_type, :resource_id]
    add_index :event_logs, :created_at
    add_index :event_logs, :deleted_at
  end

  def down
    drop_table :event_logs
  end
end
