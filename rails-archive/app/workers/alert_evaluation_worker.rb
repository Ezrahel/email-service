class AlertEvaluationWorker < ApplicationWorker
  sidekiq_options queue: :analytics, retry: 2, unique: :until_executed

  def perform
    Organization.find_each do |org|
      Alerting::AlertEngine.call(organization: org)
    rescue StandardError => e
      Rails.logger.warn "[Alerts] Failed to evaluate alerts for #{org.id}: #{e.message}"
    end
  end
end
