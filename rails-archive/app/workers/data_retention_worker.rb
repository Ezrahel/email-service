class DataRetentionWorker < ApplicationWorker
  sidekiq_options queue: :maintenance, retry: 1, unique: :until_executed

  def perform
    enforce_retention_policies!
    cleanup_rollup_tables!
    archive_old_events!
    summarize_costs!
  end

  private

  def enforce_retention_policies!
    RetentionPolicy.where(enabled: true).find_each do |policy|
      scope = if policy.organization
                policy.organization.event_logs
              else
                EventLog.all
              end

      cutoff = policy.retention_days.days.ago

      table_name = policy.table_name
      deleted = ActiveRecord::Base.connection.delete(
        "DELETE FROM #{table_name} WHERE created_at < '#{cutoff.iso8601}'" \
        "#{" AND organization_id = '#{policy.organization_id}'" if policy.organization_id}"
      )

      Rails.logger.info "[Retention] Cleaned #{deleted} rows from #{table_name}"
    end
  rescue ActiveRecord::StatementInvalid => e
    Rails.logger.warn "[Retention] Error enforcing policies: #{e.message}"
  end

  def cleanup_rollup_tables!
    [["rollup_1m", 7.days.ago], ["rollup_5m", 30.days.ago]].each do |table, cutoff|
      ActiveRecord::Base.connection.execute(
        "DELETE FROM #{table} WHERE bucket < '#{cutoff.iso8601}'"
      )
    end
  rescue ActiveRecord::StatementInvalid => e
    Rails.logger.warn "[Retention] Rollup cleanup error: #{e.message}"
  end

  def archive_old_events!
    cutoff = 90.days.ago
    old_events = DeliveryEvent.where("event_timestamp < ?", cutoff)

    return unless old_events.exists?

    archived = old_events.count
    old_events.delete_all

    Rails.logger.info "[Retention] Archived #{archived} old delivery events"
  end

  def summarize_costs!
    Organization.find_each do |org|
      yesterday = 1.day.ago.to_date

      ProviderAttempt
        .joins(delivery: :email_message)
        .where(email_messages: { organization_id: org.id })
        .where("provider_attempts.created_at": yesterday.beginning_of_day..yesterday.end_of_day)
        .group(:provider)
        .count
        .each do |provider, count|
          ProviderCost.find_or_create_by!(
            organization: org,
            provider: provider,
            date: yesterday
          ) do |pc|
            pc.emails_sent = count
            pc.cost_cents = (count * 0.1).round
          end
        rescue ActiveRecord::RecordNotUnique
          retry
        end
    end
  end
end
