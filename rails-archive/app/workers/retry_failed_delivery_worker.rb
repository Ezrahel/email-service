class RetryFailedDeliveryWorker < ApplicationWorker
  sidekiq_options queue: :maintenance, retry: 2, unique: :until_executed

  def perform
    pending = Delivery.pending.where("created_at > ?", 7.days.ago)
    failed = Delivery.where(status: "failed")
      .where("attempt_count < max_attempts")
      .where("updated_at < ?", 5.minutes.ago)
      .where("created_at > ?", 7.days.ago)
      .order(attempt_count: :asc, updated_at: :asc)
      .limit(500)

    (pending + failed).each do |delivery|
      RetryScheduler.schedule(delivery)
    end
  end
end
