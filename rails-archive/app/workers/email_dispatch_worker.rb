class EmailDispatchWorker < ApplicationWorker
  sidekiq_options queue: :deliveries, retry: 5, dead: false

  sidekiq_throttle(
    threshold: { limit: 50, period: 1.second }
  )

  def perform(delivery_id, provider_type = nil)
    delivery = Delivery.find_by(id: delivery_id)
    return unless delivery

    coordinator = DeliveryCoordinator.new(delivery: delivery, provider_type: provider_type)
    result = coordinator.dispatch!

    unless result.success?
      Rails.logger.warn({
        event: "delivery_failed",
        delivery_id: delivery.id,
        provider: result.provider,
        error: result.error
      }.to_json)
    end
  rescue StandardError => e
    report_error(delivery, e)
    raise
  end

  private

  def report_error(delivery, error)
    Sentry.capture_exception(error, extra: { delivery_id: delivery&.id }) if defined?(Sentry)
  end
end
