class AnalyticsAggregationWorker < ApplicationWorker
  sidekiq_options queue: :analytics, retry: 2, unique: :until_executed

  def perform(window = "1h")
    Analytics::EventAggregator.new(window: window).call

    if window == "1h"
      Analytics::UsageAggregator.call
    end
  end
end
