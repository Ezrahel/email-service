class BillingAggregationWorker < ApplicationWorker
  sidekiq_options queue: :analytics, retry: 2, unique: :until_executed

  def perform
    Organization.find_each do |org|
      Billing::BillingAggregator.call(organization: org)
    rescue StandardError => e
      Rails.logger.warn "[Billing] Failed to aggregate for #{org.id}: #{e.message}"
    end
  end
end
