class PartitionMaintenanceWorker < ApplicationWorker
  sidekiq_options queue: :maintenance, retry: 2, unique: :until_executed

  PARTITIONED_TABLES = %w[
    email_messages deliveries delivery_events provider_attempts
    webhook_deliveries event_logs audit_logs jobs
  ].freeze

  def perform
    PARTITIONED_TABLES.each do |table|
      create_future_partitions(table)
    end

    drop_expired_partitions!
  end

  private

  def create_future_partitions(table)
    ActiveRecord::Base.connection.execute(
      "SELECT ensure_future_partitions('#{table}', 'monthly', 3)"
    )
    Rails.logger.info "Created future partitions for #{table}"
  rescue ActiveRecord::StatementInvalid => e
    Rails.logger.warn "Failed to create partitions for #{table}: #{e.message}"
  end

  def drop_expired_partitions!
    RETENTION_MONTHS = {
      "email_messages" => 3,
      "deliveries" => 3,
      "provider_attempts" => 1,
      "delivery_events" => 3,
      "webhook_deliveries" => 1,
      "event_logs" => 1,
      "audit_logs" => 12,
      "jobs" => 1
    }.freeze

    RETENTION_MONTHS.each do |table, months|
      ActiveRecord::Base.connection.execute(
        "SELECT drop_old_partitions('#{table}', #{months})"
      )
      Rails.logger.info "Dropped old partitions for #{table} (> #{months} months)"
    rescue ActiveRecord::StatementInvalid => e
      Rails.logger.warn "Failed to drop partitions for #{table}: #{e.message}"
    end
  end
end
