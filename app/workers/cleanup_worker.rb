class CleanupWorker < ApplicationWorker
  sidekiq_options queue: :maintenance, retry: 2, unique: :until_executed

  RETENTION = {
    "event_logs" => 30.days,
    "provider_attempts" => 90.days,
    "webhook_deliveries" => 30.days,
    "audit_logs" => 1.year,
    "delivery_events" => 90.days,
    "email_messages" => 90.days,
    "deliveries" => 90.days
  }.freeze

  def perform
    RETENTION.each do |table, retention_period|
      cleanup_table(table, retention_period)
    end

    cleanup_old_partitions!
  end

  private

  def cleanup_table(table, retention)
    cutoff = (Time.current - retention).iso8601

    # For partitioned tables, drop old partitions
    begin
      count = ActiveRecord::Base.connection.execute(
        "SELECT drop_old_partitions('#{table}', #{retention.to_i / 86400 / 30})"
      )
      Rails.logger.info "Cleaned up #{table}: dropped partitions"
    rescue ActiveRecord::StatementInvalid => e
      # Fall back to delete if no partition function
      deleted = ActiveRecord::Base.connection.delete(
        "DELETE FROM #{table} WHERE created_at < '#{cutoff}'"
      )
      Rails.logger.info "Cleaned #{deleted} rows from #{table}"
    end
  end

  def cleanup_old_partitions!
    %w[email_messages deliveries delivery_events provider_attempts event_logs].each do |table|
      ActiveRecord::Base.connection.execute(
        "SELECT ensure_future_partitions('#{table}', 'monthly', 3)"
      )
    end
  rescue ActiveRecord::StatementInvalid => e
    Rails.logger.warn "Partition maintenance error: #{e.message}"
  end
end
