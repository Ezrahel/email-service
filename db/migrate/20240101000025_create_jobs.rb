class CreateJobs < ActiveRecord::Migration[8.0]
  def up
    execute <<-SQL
      CREATE TABLE jobs (
        id uuid DEFAULT gen_random_uuid() NOT NULL,
        organization_id uuid,
        job_type character varying NOT NULL,
        queue character varying NOT NULL,
        status character varying NOT NULL DEFAULT 'enqueued',
        worker_class character varying NOT NULL,
        jid character varying,
        resource_id uuid,
        resource_type character varying,
        arguments jsonb NOT NULL DEFAULT '{}'::jsonb,
        result jsonb NOT NULL DEFAULT '{}'::jsonb,
        error_class character varying,
        error_message character varying,
        attempts integer NOT NULL DEFAULT 0,
        max_attempts integer NOT NULL DEFAULT 25,
        enqueued_at timestamp with time zone,
        started_at timestamp with time zone,
        finished_at timestamp with time zone,
        failed_at timestamp with time zone,
        scheduled_at timestamp with time zone,
        duration_ms integer,
        deleted_at timestamp with time zone,
        created_at timestamp with time zone NOT NULL,
        updated_at timestamp with time zone NOT NULL,
        PRIMARY KEY (id, created_at)
      ) PARTITION BY RANGE (created_at);
    SQL

    execute <<-SQL
      CREATE TABLE jobs_202401 PARTITION OF jobs
        FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');
    SQL
    execute <<-SQL
      CREATE TABLE jobs_202402 PARTITION OF jobs
        FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');
    SQL
    execute <<-SQL
      CREATE TABLE jobs_202403 PARTITION OF jobs
        FOR VALUES FROM ('2024-03-01') TO ('2024-04-01');
    SQL
    execute <<-SQL
      CREATE TABLE jobs_202404 PARTITION OF jobs
        FOR VALUES FROM ('2024-04-01') TO ('2024-05-01');
    SQL
    execute <<-SQL
      CREATE TABLE jobs_202405 PARTITION OF jobs
        FOR VALUES FROM ('2024-05-01') TO ('2024-06-01');
    SQL
    execute <<-SQL
      CREATE TABLE jobs_202406 PARTITION OF jobs
        FOR VALUES FROM ('2024-06-01') TO ('2024-07-01');
    SQL
    execute <<-SQL
      CREATE TABLE jobs_202407 PARTITION OF jobs
        FOR VALUES FROM ('2024-07-01') TO ('2024-08-01');
    SQL
    execute <<-SQL
      CREATE TABLE jobs_202408 PARTITION OF jobs
        FOR VALUES FROM ('2024-08-01') TO ('2024-09-01');
    SQL
    execute <<-SQL
      CREATE TABLE jobs_202409 PARTITION OF jobs
        FOR VALUES FROM ('2024-09-01') TO ('2024-10-01');
    SQL
    execute <<-SQL
      CREATE TABLE jobs_202410 PARTITION OF jobs
        FOR VALUES FROM ('2024-10-01') TO ('2024-11-01');
    SQL
    execute <<-SQL
      CREATE TABLE jobs_202411 PARTITION OF jobs
        FOR VALUES FROM ('2024-11-01') TO ('2024-12-01');
    SQL
    execute <<-SQL
      CREATE TABLE jobs_202412 PARTITION OF jobs
        FOR VALUES FROM ('2024-12-01') TO ('2025-01-01');
    SQL

    add_index :jobs, :jid, unique: true, where: "jid IS NOT NULL"
    add_index :jobs, :organization_id
    add_index :jobs, :status
    add_index :jobs, :job_type
    add_index :jobs, :queue
    add_index :jobs, [:resource_type, :resource_id]
    add_index :jobs, :scheduled_at, where: "scheduled_at IS NOT NULL AND status = 'enqueued'"
    add_index :jobs, :created_at
    add_index :jobs, :deleted_at
  end

  def down
    drop_table :jobs
  end
end
