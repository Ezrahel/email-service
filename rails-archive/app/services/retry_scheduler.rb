class RetryScheduler
  class << self
    def schedule(delivery)
      return unless delivery.retryable?

      delay = RetryPolicy.delay_for(delivery.attempt_count + 1)

      delivery.update!(status: "pending", last_retry_at: Time.current)

      EmailDispatchWorker.perform_in(delay.to_i, delivery.id, delivery.provider)

      Rails.logger.info({
        event: "delivery_retry_scheduled",
        delivery_id: delivery.id,
        email_id: delivery.email_message_id,
        attempt: delivery.attempt_count + 1,
        delay: delay.to_i,
        scheduled_at: (Time.current + delay).iso8601
      }.to_json)
    end

    def schedule_all(pending_deliveries)
      pending_deliveries.find_each do |delivery|
        schedule(delivery)
      end
    end
  end
end
