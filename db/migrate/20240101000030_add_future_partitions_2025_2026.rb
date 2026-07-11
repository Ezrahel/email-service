class AddFuturePartitions20252026 < ActiveRecord::Migration[8.0]
  PARTITIONED_TABLES = %w[
    email_messages deliveries delivery_events provider_attempts
    audit_logs event_logs jobs webhook_deliveries
  ].freeze

  def up
    PARTITIONED_TABLES.each do |table|
      create_partitions_for_years(table, [2025, 2026])
    end

    # rollup tables - quarterly partitions for 2025-2026
    %w[rollup_1m rollup_5m].each do |table|
      [2025, 2026].each do |year|
        [1, 2, 3, 4].each do |quarter|
          start_month = (quarter - 1) * 3 + 1
          start_date = Date.new(year, start_month, 1)
          end_date = start_date >> 3
          execute <<-SQL
            CREATE TABLE IF NOT EXISTS #{table}_#{year}_q#{quarter}
            PARTITION OF #{table}
            FOR VALUES FROM ('#{start_date}') TO ('#{end_date}');
          SQL
        end
      end
    end

    # rollup_daily_domain - yearly partitions for 2025-2026
    [2025, 2026].each do |year|
      execute <<-SQL
        CREATE TABLE IF NOT EXISTS rollup_daily_domain_#{year}
        PARTITION OF rollup_daily_domain
        FOR VALUES FROM ('#{year}-01-01') TO ('#{year + 1}-01-01');
      SQL
    end

    # usage_records - monthly partitions for 2025-2026
    [2025, 2026].each do |year|
      (1..12).each do |month|
        m = month.to_s.rjust(2, '0')
        execute <<-SQL
          CREATE TABLE IF NOT EXISTS usage_records_#{year}#{m}
          PARTITION OF usage_records
          FOR VALUES FROM ('#{year}-#{m}-01') TO ('#{(month == 12 ? year + 1 : year)}-#{(month == 12 ? '01' : (month + 1).to_s.rjust(2, '0'))}-01');
        SQL
      end
    end
  end

  def down
    PARTITIONED_TABLES.each do |table|
      drop_partitions_for_years(table, [2026, 2025])
    end
    [2026, 2025].each do |year|
      [1, 2, 3, 4].each do |quarter|
        %w[rollup_1m rollup_5m].each do |table|
          execute "DROP TABLE IF EXISTS #{table}_#{year}_q#{quarter}"
        end
        execute "DROP TABLE IF EXISTS rollup_daily_domain_#{year}"
      end
      (1..12).each do |month|
        m = month.to_s.rjust(2, '0')
        execute "DROP TABLE IF EXISTS usage_records_#{year}#{m}"
      end
    end
  end

  private

  def create_partitions_for_years(table, years)
    years.each do |year|
      (1..12).each do |month|
        m = month.to_s.rjust(2, '0')
        execute <<-SQL
          CREATE TABLE IF NOT EXISTS #{table}_#{year}#{m}
          PARTITION OF #{table}
          FOR VALUES FROM ('#{year}-#{m}-01') TO ('#{(month == 12 ? year + 1 : year)}-#{(month == 12 ? '01' : (month + 1).to_s.rjust(2, '0'))}-01');
        SQL
      end
    end
  end

  def drop_partitions_for_years(table, years)
    years.each do |year|
      (1..12).each do |month|
        m = month.to_s.rjust(2, '0')
        execute "DROP TABLE IF EXISTS #{table}_#{year}#{m}"
      end
    end
  end
end