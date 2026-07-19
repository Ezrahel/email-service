module Operations
  class AdminOperations < ApplicationService
    def replay_delivery(email_message_id:)
      email = EmailMessage.find(email_message_id)
      raise "Email already delivered" if email.status == "delivered"

      email.update!(status: "queued")
      EmailDispatchWorker.perform_async(email.id)

      Operations::AuditService.call(
        action: "retry",
        resource_type: "email_message",
        resource_id: email.id,
        organization: email.organization,
        metadata: { operation: "replay_delivery" }
      )

      { replayed: true, email_id: email.id }
    end

    def cancel_email(email_message_id:)
      email = EmailMessage.find(email_message_id)
      raise "Cannot cancel delivered email" if %w[delivered failed bounced].include?(email.status)

      email.update!(status: "cancelled")

      Operations::AuditService.call(
        action: "update",
        resource_type: "email_message",
        resource_id: email.id,
        organization: email.organization,
        changes: { status: ["queued", "cancelled"] },
        metadata: { operation: "cancel_email" }
      )

      { cancelled: true, email_id: email.id }
    end

    def pause_provider(provider_config_id:)
      config = ProviderConfig.find(provider_config_id)
      config.update!(enabled: false)

      Operations::AuditService.call(
        action: "pause",
        resource_type: "provider_config",
        resource_id: config.id,
        organization: config.organization,
        changes: { enabled: [true, false] },
        metadata: { provider: config.provider, operation: "pause_provider" }
      )

      { paused: true, provider_config_id: config.id, provider: config.provider }
    end

    def resume_provider(provider_config_id:)
      config = ProviderConfig.find(provider_config_id)
      config.update!(enabled: true)

      Operations::AuditService.call(
        action: "resume",
        resource_type: "provider_config",
        resource_id: config.id,
        organization: config.organization,
        changes: { enabled: [false, true] },
        metadata: { provider: config.provider, operation: "resume_provider" }
      )

      { resumed: true, provider_config_id: config.id, provider: config.provider }
    end

    def resend_webhook(webhook_delivery_id:)
      delivery = WebhookDelivery.find(webhook_delivery_id)
      WebhookDeliveryWorker.perform_async(delivery.webhook_id, delivery.event_id)

      Operations::AuditService.call(
        action: "webhook_delivery",
        resource_type: "webhook",
        resource_id: delivery.webhook_id,
        organization: delivery.webhook.organization,
        metadata: { operation: "resend_webhook", webhook_delivery_id: delivery.id }
      )

      { rescheduled: true, webhook_delivery_id: delivery.id }
    end

    def reprocess_event(event_log_id:)
      event = EventLog.find(event_log_id)
      event.update!(processed_at: nil)
      EventConsumer.new.process_event(event)

      Operations::AuditService.call(
        action: "retry",
        resource_type: "email_metric",
        resource_id: event.id,
        metadata: { operation: "reprocess_event", event_type: event.event_type }
      )

      { reprocessed: true, event_log_id: event.id }
    end
  end
end
