class EventPublisher
  STREAM_KEY = "events:delivery"

  class << self
    def publish(event_type:, organization_id:, payload: {})
      event = {
        event_type: event_type,
        organization_id: organization_id,
        payload: payload.to_json,
        timestamp: Time.current.iso8601(3),
        request_id: Current.request_id
      }

      REDIS_STREAMS.xadd(STREAM_KEY, event, maxlen: 100_000)

      EventRecorder.record(
        event_type: event_type,
        organization_id: organization_id,
        payload: payload
      )

      WebhookDispatcher.dispatch_async(
        event_type: event_type,
        organization_id: organization_id,
        payload: payload
      )

      Rails.logger.debug {
        { event: "event_published", event_type: event_type, organization_id: organization_id }.to_json
      }

      true
    rescue Redis::CommandError => e
      Rails.logger.error "Event publish failed: #{e.message}"
      EventRecorder.record(
        event_type: event_type,
        organization_id: organization_id,
        payload: payload
      )
      false
    end
  end
end
