class CreatePartitionManagement < ActiveRecord::Migration[8.0]
  def up
    # Function to create a new monthly partition for a given table
    execute <<-SQL
      CREATE OR REPLACE FUNCTION create_monthly_partition(
        parent_table text,
        partition_date timestamptz
      ) RETURNS void AS $$
      DECLARE
        partition_name text;
        start_date text;
        end_date text;
      BEGIN
        partition_name := parent_table || '_' || to_char(partition_date, 'YYYYMM');
        start_date := to_char(partition_date, 'YYYY-MM-01');
        end_date := to_char(partition_date + interval '1 month', 'YYYY-MM-01');

        EXECUTE format(
          'CREATE TABLE IF NOT EXISTS %I PARTITION OF %I
           FOR VALUES FROM (%L) TO (%L)',
          partition_name, parent_table, start_date, end_date
        );
      END;
      $$ LANGUAGE plpgsql;
    SQL

    # Function to create a new daily partition for high-volume tables
    execute <<-SQL
      CREATE OR REPLACE FUNCTION create_daily_partition(
        parent_table text,
        partition_date date
      ) RETURNS void AS $$
      DECLARE
        partition_name text;
        start_date text;
        end_date text;
      BEGIN
        partition_name := parent_table || '_' || to_char(partition_date, 'YYYYMMDD');
        start_date := to_char(partition_date, 'YYYY-MM-DD');
        end_date := to_char(partition_date + interval '1 day', 'YYYY-MM-DD');

        EXECUTE format(
          'CREATE TABLE IF NOT EXISTS %I PARTITION OF %I
           FOR VALUES FROM (%L) TO (%L)',
          partition_name, parent_table, start_date, end_date
        );
      END;
      $$ LANGUAGE plpgsql;
    SQL

    # Function to create partitions proactively (next N months)
    execute <<-SQL
      CREATE OR REPLACE FUNCTION ensure_future_partitions(
        parent_table text,
        partition_type text DEFAULT 'monthly',
        months_ahead int DEFAULT 3
      ) RETURNS void AS $$
      DECLARE
        i int;
        partition_date timestamptz;
      BEGIN
        FOR i IN 0..months_ahead LOOP
          partition_date := date_trunc('month', now()) + (i || ' months')::interval;

          IF partition_type = 'daily' THEN
            PERFORM create_daily_partition(parent_table, partition_date::date);
          ELSE
            PERFORM create_monthly_partition(parent_table, partition_date);
          END IF;
        END LOOP;
      END;
      $$ LANGUAGE plpgsql;
    SQL

    # Function to drop old partitions (retention enforcement)
    execute <<-SQL
      CREATE OR REPLACE FUNCTION drop_old_partitions(
        parent_table text,
        retention_months int DEFAULT 3
      ) RETURNS int AS $$
      DECLARE
        boundary_date date;
        partition_name text;
        dropped_count int := 0;
      BEGIN
        boundary_date := date_trunc('month', now() - (retention_months || ' months')::interval)::date;

        FOR partition_name IN
          SELECT inhrelid::regclass::text
          FROM pg_inherits
          WHERE inhparent = parent_table::regclass
            AND inhrelid::regclass::text LIKE parent_table || '_%'
        LOOP
          EXECUTE format('DROP TABLE IF EXISTS %I', partition_name);
          dropped_count := dropped_count + 1;
        END LOOP;

        RETURN dropped_count;
      END;
      $$ LANGUAGE plpgsql;
    SQL
  end

  def down
    execute "DROP FUNCTION IF EXISTS drop_old_partitions(text, int)"
    execute "DROP FUNCTION IF EXISTS ensure_future_partitions(text, text, int)"
    execute "DROP FUNCTION IF EXISTS create_daily_partition(text, date)"
    execute "DROP FUNCTION IF EXISTS create_monthly_partition(text, timestamptz)"
  end
end
