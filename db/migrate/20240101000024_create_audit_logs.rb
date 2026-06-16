class CreateAuditLogs < ActiveRecord::Migration[8.0]
  def up
    execute <<-SQL
      CREATE TABLE audit_logs (
        id uuid DEFAULT gen_random_uuid() NOT NULL,
        organization_id uuid,
        user_id uuid,
        api_key_id uuid,
        action character varying NOT NULL,
        resource_type character varying NOT NULL,
        resource_id uuid,
        changes jsonb NOT NULL DEFAULT '{}'::jsonb,
        metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
        ip_address character varying,
        user_agent character varying,
        request_id character varying,
        event_timestamp timestamp with time zone NOT NULL,
        deleted_at timestamp with time zone,
        created_at timestamp with time zone NOT NULL,
        updated_at timestamp with time zone NOT NULL,
        PRIMARY KEY (id, created_at)
      ) PARTITION BY RANGE (created_at);
    SQL

    execute <<-SQL
      CREATE TABLE audit_logs_202401 PARTITION OF audit_logs
        FOR VALUES FROM ('2024-01-01') TO ('2024-04-01');
    SQL
    execute <<-SQL
      CREATE TABLE audit_logs_202404 PARTITION OF audit_logs
        FOR VALUES FROM ('2024-04-01') TO ('2024-07-01');
    SQL
    execute <<-SQL
      CREATE TABLE audit_logs_202407 PARTITION OF audit_logs
        FOR VALUES FROM ('2024-07-01') TO ('2024-10-01');
    SQL
    execute <<-SQL
      CREATE TABLE audit_logs_202410 PARTITION OF audit_logs
        FOR VALUES FROM ('2024-10-01') TO ('2025-01-01');
    SQL

    add_index :audit_logs, :organization_id
    add_index :audit_logs, :user_id
    add_index :audit_logs, :action
    add_index :audit_logs, :resource_type
    add_index :audit_logs, [:resource_type, :resource_id]
    add_index :audit_logs, :event_timestamp
    add_index :audit_logs, [:organization_id, :event_timestamp]
    add_index :audit_logs, :request_id
    add_index :audit_logs, :created_at
    add_index :audit_logs, :deleted_at
  end

  def down
    drop_table :audit_logs
  end
end
