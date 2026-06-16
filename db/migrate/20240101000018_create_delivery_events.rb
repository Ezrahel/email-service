class CreateDeliveryEvents < ActiveRecord::Migration[8.0]
  def up
    execute <<-SQL
      CREATE TABLE delivery_events (
        id uuid DEFAULT gen_random_uuid() NOT NULL,
        delivery_id uuid NOT NULL,
        email_message_id uuid NOT NULL,
        organization_id uuid NOT NULL,
        event_type character varying NOT NULL,
        provider character varying NOT NULL,
        ip_address character varying,
        user_agent character varying,
        metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
        provider_event_id character varying,
        event_timestamp timestamp with time zone NOT NULL,
        processed_at timestamp with time zone,
        deleted_at timestamp with time zone,
        created_at timestamp with time zone NOT NULL,
        updated_at timestamp with time zone NOT NULL,
        PRIMARY KEY (id, created_at)
      ) PARTITION BY RANGE (created_at);
    SQL

    execute <<-SQL
      CREATE TABLE delivery_events_202401 PARTITION OF delivery_events
        FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');
    SQL
    execute <<-SQL
      CREATE TABLE delivery_events_202402 PARTITION OF delivery_events
        FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');
    SQL
    execute <<-SQL
      CREATE TABLE delivery_events_202403 PARTITION OF delivery_events
        FOR VALUES FROM ('2024-03-01') TO ('2024-04-01');
    SQL
    execute <<-SQL
      CREATE TABLE delivery_events_202404 PARTITION OF delivery_events
        FOR VALUES FROM ('2024-04-01') TO ('2024-05-01');
    SQL
    execute <<-SQL
      CREATE TABLE delivery_events_202405 PARTITION OF delivery_events
        FOR VALUES FROM ('2024-05-01') TO ('2024-06-01');
    SQL
    execute <<-SQL
      CREATE TABLE delivery_events_202406 PARTITION OF delivery_events
        FOR VALUES FROM ('2024-06-01') TO ('2024-07-01');
    SQL
    execute <<-SQL
      CREATE TABLE delivery_events_202407 PARTITION OF delivery_events
        FOR VALUES FROM ('2024-07-01') TO ('2024-08-01');
    SQL
    execute <<-SQL
      CREATE TABLE delivery_events_202408 PARTITION OF delivery_events
        FOR VALUES FROM ('2024-08-01') TO ('2024-09-01');
    SQL
    execute <<-SQL
      CREATE TABLE delivery_events_202409 PARTITION OF delivery_events
        FOR VALUES FROM ('2024-09-01') TO ('2024-10-01');
    SQL
    execute <<-SQL
      CREATE TABLE delivery_events_202410 PARTITION OF delivery_events
        FOR VALUES FROM ('2024-10-01') TO ('2024-11-01');
    SQL
    execute <<-SQL
      CREATE TABLE delivery_events_202411 PARTITION OF delivery_events
        FOR VALUES FROM ('2024-11-01') TO ('2024-12-01');
    SQL
    execute <<-SQL
      CREATE TABLE delivery_events_202412 PARTITION OF delivery_events
        FOR VALUES FROM ('2024-12-01') TO ('2025-01-01');
    SQL

    add_index :delivery_events, :delivery_id
    add_index :delivery_events, :email_message_id
    add_index :delivery_events, :event_type
    add_index :delivery_events, :provider
    add_index :delivery_events, :event_timestamp
    add_index :delivery_events, :processed_at, where: "processed_at IS NULL"
    add_index :delivery_events, [:organization_id, :event_type, :event_timestamp]
    add_index :delivery_events, [:organization_id, :event_timestamp]
    add_index :delivery_events, :provider_event_id, where: "provider_event_id IS NOT NULL"
    add_index :delivery_events, :created_at
    add_index :delivery_events, :deleted_at
  end

  def down
    drop_table :delivery_events
  end
end
