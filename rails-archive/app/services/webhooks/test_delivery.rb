module Webhooks
  class TestDelivery < ApplicationService
    def initialize(webhook:)
      @webhook = webhook
    end

    def call
      event = {
        type: "webhook.test",
        id: SecureRandom.uuid,
        timestamp: Time.current.iso8601,
        data: {
          message: "This is a test webhook event",
          webhook_id: @webhook.id
        }
      }

      WebhookDelivery.create!(
        webhook: @webhook,
        organization: @webhook.organization,
        event_type: "webhook.test",
        event_id: event[:id],
        status: "pending",
        request_body: event.to_json
      )

      # Actual delivery happens in background worker (Phase 5)
      self
    end
  end
end
