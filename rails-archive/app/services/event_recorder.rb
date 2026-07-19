class EventRecorder
  class << self
    def record(event_type:, organization_id:, payload: {})
      EventLog.create!(
        organization_id: organization_id,
        event_type: event_type,
        payload: payload,
        source: "email_service",
        event_timestamp: Time.current
      )
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error "Failed to record event: #{e.message}"
    end

    def record_delivery_event(delivery:, event_type:, metadata: {})
      delivery.delivery_events.create!(
        email_message_id: delivery.email_message_id,
        organization_id: delivery.organization_id,
        event_type: event_type,
        provider: delivery.provider,
        event_timestamp: Time.current,
        metadata: metadata
      )
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error "Failed to record delivery event: #{e.message}"
    end
  end
end
