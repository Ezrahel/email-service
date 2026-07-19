class CreateProviderAttempts < ActiveRecord::Migration[8.0]
  def up
    execute <<-SQL
      CREATE TABLE provider_attempts (
        id uuid DEFAULT gen_random_uuid() NOT NULL,
        delivery_id uuid NOT NULL,
        organization_id uuid NOT NULL,
        attempt_number integer NOT NULL,
        provider character varying NOT NULL,
        status character varying NOT NULL DEFAULT 'pending',
        duration_ms integer,
        http_status integer,
        provider_message_id character varying,
        request_body text,
        response_body text,
        response_headers jsonb NOT NULL DEFAULT '{}'::jsonb,
        error_class character varying,
        error_message character varying,
        error_code character varying,
        circuit_open boolean NOT NULL DEFAULT false,
        retryable boolean NOT NULL DEFAULT true,
        deleted_at timestamp with time zone,
        created_at timestamp with time zone NOT NULL,
        updated_at timestamp with time zone NOT NULL,
        PRIMARY KEY (id, created_at)
      ) PARTITION BY RANGE (created_at);
    SQL

    execute <<-SQL
      CREATE TABLE provider_attempts_202401 PARTITION OF provider_attempts
        FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');
    SQL
    execute <<-SQL
      CREATE TABLE provider_attempts_202402 PARTITION OF provider_attempts
        FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');
    SQL
    execute <<-SQL
      CREATE TABLE provider_attempts_202403 PARTITION OF provider_attempts
        FOR VALUES FROM ('2024-03-01') TO ('2024-04-01');
    SQL
    execute <<-SQL
      CREATE TABLE provider_attempts_202404 PARTITION OF provider_attempts
        FOR VALUES FROM ('2024-04-01') TO ('2024-05-01');
    SQL
    execute <<-SQL
      CREATE TABLE provider_attempts_202405 PARTITION OF provider_attempts
        FOR VALUES FROM ('2024-05-01') TO ('2024-06-01');
    SQL
    execute <<-SQL
      CREATE TABLE provider_attempts_202406 PARTITION OF provider_attempts
        FOR VALUES FROM ('2024-06-01') TO ('2024-07-01');
    SQL
    execute <<-SQL
      CREATE TABLE provider_attempts_202407 PARTITION OF provider_attempts
        FOR VALUES FROM ('2024-07-01') TO ('2024-08-01');
    SQL
    execute <<-SQL
      CREATE TABLE provider_attempts_202408 PARTITION OF provider_attempts
        FOR VALUES FROM ('2024-08-01') TO ('2024-09-01');
    SQL
    execute <<-SQL
      CREATE TABLE provider_attempts_202409 PARTITION OF provider_attempts
        FOR VALUES FROM ('2024-09-01') TO ('2024-10-01');
    SQL
    execute <<-SQL
      CREATE TABLE provider_attempts_202410 PARTITION OF provider_attempts
        FOR VALUES FROM ('2024-10-01') TO ('2024-11-01');
    SQL
    execute <<-SQL
      CREATE TABLE provider_attempts_202411 PARTITION OF provider_attempts
        FOR VALUES FROM ('2024-11-01') TO ('2024-12-01');
    SQL
    execute <<-SQL
      CREATE TABLE provider_attempts_202412 PARTITION OF provider_attempts
        FOR VALUES FROM ('2024-12-01') TO ('2025-01-01');
    SQL

    add_index :provider_attempts, :delivery_id
    add_index :provider_attempts, :organization_id
    add_index :provider_attempts, :status
    add_index :provider_attempts, :provider
    add_index :provider_attempts, [:organization_id, :created_at]
    add_index :provider_attempts, :created_at
    add_index :provider_attempts, :deleted_at
  end

  def down
    drop_table :provider_attempts
  end
end
