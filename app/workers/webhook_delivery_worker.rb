class WebhookDeliveryWorker < ApplicationWorker
  sidekiq_options queue: :webhooks, retry: 3, dead: true

  sidekiq_throttle(
    threshold: { limit: 30, period: 1.second }
  )

  def perform(webhook_delivery_id)
    delivery = WebhookDelivery.find_by(id: webhook_delivery_id)
    return unless delivery
    return unless delivery.status == "pending"

    dispatcher = WebhookDispatcher.new(delivery: delivery)
    result = dispatcher.deliver!

    if result.success?
      delivery.mark_delivered!(
        http_status: result.http_status,
        duration_ms: result.duration_ms,
        response_body: result.response_body
      )

      delivery.webhook.update!(last_sent_at: Time.current, last_success_at: Time.current)
    else
      delivery.mark_failed!(error_message: result.error, http_status: result.http_status)

      if delivery.retryable?
        WebhookDeliveryWorker.perform_in(backoff_seconds(delivery.attempt), delivery.id)
      end
    end
  rescue StandardError => e
    Rails.logger.error "Webhook delivery failed: #{e.message}"
    raise
  end

  private

  def backoff_seconds(attempt)
    (2 ** attempt) + rand(0..5)
  end
end
