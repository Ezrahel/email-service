class CreateEmailMessages < ActiveRecord::Migration[8.0]
  def up
    execute <<-SQL
      CREATE TABLE email_messages (
        id uuid DEFAULT gen_random_uuid() NOT NULL,
        organization_id uuid NOT NULL,
        batch_id uuid NOT NULL,
        template_id uuid,
        domain_id uuid,
        from_address character varying NOT NULL,
        to_address character varying NOT NULL,
        recipient_type character varying NOT NULL DEFAULT 'to',
        subject character varying NOT NULL,
        html_body text,
        text_body text,
        headers jsonb NOT NULL DEFAULT '{}'::jsonb,
        tags jsonb NOT NULL DEFAULT '[]'::jsonb,
        status character varying NOT NULL DEFAULT 'queued',
        idempotency_key character varying,
        reply_to character varying,
        message_id character varying,
        retry_count integer NOT NULL DEFAULT 0,
        max_retries integer NOT NULL DEFAULT 3,
        scheduled_at timestamp with time zone,
        sent_at timestamp with time zone,
        delivered_at timestamp with time zone,
        failed_at timestamp with time zone,
        last_retry_at timestamp with time zone,
        failure_reason character varying,
        failure_code character varying,
        deleted_at timestamp with time zone,
        created_at timestamp with time zone NOT NULL,
        updated_at timestamp with time zone NOT NULL,
        PRIMARY KEY (id, created_at)
      ) PARTITION BY RANGE (created_at);
    SQL

    execute <<-SQL
      CREATE TABLE email_messages_202401 PARTITION OF email_messages
        FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');
    SQL
    execute <<-SQL
      CREATE TABLE email_messages_202402 PARTITION OF email_messages
        FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');
    SQL
    execute <<-SQL
      CREATE TABLE email_messages_202403 PARTITION OF email_messages
        FOR VALUES FROM ('2024-03-01') TO ('2024-04-01');
    SQL
    execute <<-SQL
      CREATE TABLE email_messages_202404 PARTITION OF email_messages
        FOR VALUES FROM ('2024-04-01') TO ('2024-05-01');
    SQL
    execute <<-SQL
      CREATE TABLE email_messages_202405 PARTITION OF email_messages
        FOR VALUES FROM ('2024-05-01') TO ('2024-06-01');
    SQL
    execute <<-SQL
      CREATE TABLE email_messages_202406 PARTITION OF email_messages
        FOR VALUES FROM ('2024-06-01') TO ('2024-07-01');
    SQL
    execute <<-SQL
      CREATE TABLE email_messages_202407 PARTITION OF email_messages
        FOR VALUES FROM ('2024-07-01') TO ('2024-08-01');
    SQL
    execute <<-SQL
      CREATE TABLE email_messages_202408 PARTITION OF email_messages
        FOR VALUES FROM ('2024-08-01') TO ('2024-09-01');
    SQL
    execute <<-SQL
      CREATE TABLE email_messages_202409 PARTITION OF email_messages
        FOR VALUES FROM ('2024-09-01') TO ('2024-10-01');
    SQL
    execute <<-SQL
      CREATE TABLE email_messages_202410 PARTITION OF email_messages
        FOR VALUES FROM ('2024-10-01') TO ('2024-11-01');
    SQL
    execute <<-SQL
      CREATE TABLE email_messages_202411 PARTITION OF email_messages
        FOR VALUES FROM ('2024-11-01') TO ('2024-12-01');
    SQL
    execute <<-SQL
      CREATE TABLE email_messages_202412 PARTITION OF email_messages
        FOR VALUES FROM ('2024-12-01') TO ('2025-01-01');
    SQL

    add_index :email_messages, :organization_id
    add_index :email_messages, :batch_id
    add_index :email_messages, :to_address
    add_index :email_messages, :status
    add_index :email_messages, :idempotency_key, where: "idempotency_key IS NOT NULL"
    add_index :email_messages, :message_id, where: "message_id IS NOT NULL"
    add_index :email_messages, [:organization_id, :status, :created_at]
    add_index :email_messages, [:organization_id, :created_at]
    add_index :email_messages, :scheduled_at, where: "scheduled_at IS NOT NULL AND status = 'queued'"
    add_index :email_messages, :created_at
    add_index :email_messages, :tags, using: :gin
    add_index :email_messages, :deleted_at
  end

  def down
    drop_table :email_messages
  end
end
