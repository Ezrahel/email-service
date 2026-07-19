module EmailPipeline
  class Orchestrator < ApplicationService
    def initialize(email:)
      @email = email
    end

    def call
      return unless @email

      # Stage 1: Validate
      EmailPipeline::Validator.call(email: @email)

      # Stage 2: Render template (if applicable)
      EmailPipeline::TemplateRenderer.call(email: @email)

      # Stage 3: Expand recipients
      recipients = EmailPipeline::RecipientExpander.call(email: @email)
      return if recipients.empty?

      # Stage 4: Build MIME message
      mime_message = EmailPipeline::MimeBuilder.call(email: @email)

      # Stage 5: Ensure delivery record exists
      delivery = @email.delivery || @email.create_delivery!(
        organization: @email.organization,
        status: "pending",
        provider: "pending",
        max_attempts: 3
      )

      # Stage 6: Select provider and enqueue dispatch
      provider = ProviderRouter.select_provider(
        organization: @email.organization,
        email: @email
      )

      if provider
        delivery.update!(provider: provider.provider_type)

        EmailDispatchWorker.perform_async(delivery.id, provider.provider_type)
      else
        delivery.mark_failed!(reason: "No available email provider")
        @email.mark_failed!(reason: "No available email provider")
      end

      # Stage 7: Record events
      EventPublisher.publish(
        event_type: "email.queued",
        organization_id: @email.organization_id,
        payload: {
          email_id: @email.id,
          delivery_id: delivery.id,
          to: @email.to_address,
          subject: @email.subject
        }
      )

      @email
    end
  end
end
