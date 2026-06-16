class DeadLetterService
  class << self
    def send(delivery)
      delivery.update!(status: "failed")

      EventPublisher.publish(
        event_type: "email.dead_letter",
        organization_id: delivery.organization_id,
        payload: {
          delivery_id: delivery.id,
          email_id: delivery.email_message_id,
          provider: delivery.provider,
          attempts: delivery.attempt_count,
          max_attempts: delivery.max_attempts,
          last_error: delivery.failure_reason
        }
      )

      Rails.logger.warn({
        event: "delivery_dead_lettered",
        delivery_id: delivery.id,
        email_id: delivery.email_message_id,
        attempts: delivery.attempt_count,
        error: delivery.failure_reason
      }.to_json)
    end

    def replay(dead_delivery_id, organization_id: nil)
      delivery = Delivery.find_by(id: dead_delivery_id)
      return unless delivery

      if organization_id && delivery.organization_id != organization_id
        raise Errors::ForbiddenError, "Delivery does not belong to this organization"
      end

      delivery.update!(
        status: "pending",
        attempt_count: 0,
        failure_reason: nil,
        failure_code: nil
      )

      EmailDispatchWorker.perform_async(delivery.id, delivery.provider)
    end

    def list(organization_id:, limit: 50)
      Delivery.where(organization_id: organization_id, status: "failed")
        .where("attempt_count >= max_attempts")
        .order(updated_at: :desc)
        .limit(limit)
    end
  end
end
