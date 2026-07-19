module Providers
  module Webhooks
    class WebhookProcessor
      def initialize(provider_type:)
        @validator = WebhookValidator.new(provider_type)
        @provider_type = provider_type
      end

      def process(request)
        validation = @validator.validate(request)
        return validation unless validation.valid?

        processed = process_event(validation)
        processed
      end

      private

      def process_event(validation)
        event_type = validation.event_type
        payload = validation.payload

        case event_type
        when "delivered"  then handle_delivered(payload)
        when "bounced"    then handle_bounced(payload)
        when "complained" then handle_complaint(payload)
        when "opened"     then handle_open(payload)
        when "clicked"    then handle_click(payload)
        when "rejected"   then handle_rejected(payload)
        when "failed"     then handle_failed(payload)
        when "sent"       then handle_sent(payload)
        else
          WebhookValidator::ValidationResult.new(
            valid: true,
            event_type: event_type,
            provider: @provider_type,
            payload: payload,
            error: "Unhandled event type: #{event_type}"
          )
        end
      rescue StandardError => e
        WebhookValidator::ValidationResult.new(
          valid: false,
          error: "Processing error: #{e.message}"
        )
      end

      def handle_delivered(payload)
        message_id = extract_message_id(payload, "delivered")
        return no_message_id("delivered") unless message_id

        delivery = find_delivery(message_id)
        return delivery_not_found(message_id) unless delivery

        return already_processed(message_id) if delivery.status == "delivered"

        delivery.mark_delivered!
        delivery.email_message&.mark_delivered!

        EventPublisher.publish(
          event_type: "email.delivered",
          organization_id: delivery.organization_id,
          payload: {
            email_id: delivery.email_message_id,
            delivery_id: delivery.id,
            provider: @provider_type,
            provider_message_id: message_id,
            timestamp: payload["timestamp"]
          }
        )

        WebhookValidator::ValidationResult.new(
          valid: true, event_type: "delivered",
          provider: @provider_type, payload: payload
        )
      end

      def handle_bounced(payload)
        message_id = extract_message_id(payload, "bounced")
        return no_message_id("bounced") unless message_id

        delivery = find_delivery_any(message_id)
        return delivery_not_found(message_id) unless delivery

        bounce_type = extract_bounce_type(payload)
        delivery.update!(
          status: "bounced",
          bounce_type: bounce_type,
          bounced_at: Time.current
        )
        delivery.email_message&.mark_bounced!(reason: payload["error"] || "Bounced")

        EventPublisher.publish(
          event_type: "email.bounced",
          organization_id: delivery.organization_id,
          payload: {
            email_id: delivery.email_message_id,
            delivery_id: delivery.id,
            provider: @provider_type,
            bounce_type: bounce_type,
            error: payload["error"]
          }
        )

        WebhookValidator::ValidationResult.new(
          valid: true, event_type: "bounced",
          provider: @provider_type, payload: payload
        )
      end

      def handle_complaint(payload)
        message_id = extract_message_id(payload, "complained")
        return no_message_id("complaint") unless message_id

        delivery = find_delivery_any(message_id)
        return delivery_not_found(message_id) unless delivery

        delivery.update!(status: "complained", complaint_at: Time.current)

        EventPublisher.publish(
          event_type: "email.complained",
          organization_id: delivery.organization_id,
          payload: {
            email_id: delivery.email_message_id,
            delivery_id: delivery.id,
            provider: @provider_type
          }
        )

        WebhookValidator::ValidationResult.new(
          valid: true, event_type: "complained",
          provider: @provider_type, payload: payload
        )
      end

      def handle_open(payload)
        message_id = extract_message_id(payload, "opened")
        return no_message_id("open") unless message_id

        delivery = find_delivery_any(message_id)
        return delivery_not_found(message_id) unless delivery

        delivery.update!(
          opened_at: delivery.opened_at || Time.current,
          open_count: delivery.open_count + 1
        )

        WebhookValidator::ValidationResult.new(
          valid: true, event_type: "opened",
          provider: @provider_type, payload: payload
        )
      end

      def handle_click(payload)
        message_id = extract_message_id(payload, "clicked")
        return no_message_id("click") unless message_id

        delivery = find_delivery_any(message_id)
        return delivery_not_found(message_id) unless delivery

        delivery.update!(
          clicked_at: delivery.clicked_at || Time.current,
          click_count: delivery.click_count + 1
        )

        WebhookValidator::ValidationResult.new(
          valid: true, event_type: "clicked",
          provider: @provider_type, payload: payload
        )
      end

      def handle_rejected(payload)
        message_id = extract_message_id(payload, "rejected")
        return no_message_id("rejected") unless message_id

        delivery = find_delivery_any(message_id)
        return delivery_not_found(message_id) unless delivery

        delivery.mark_failed!(reason: "Rejected by provider")
        delivery.email_message&.mark_failed!(reason: "Rejected by provider")

        WebhookValidator::ValidationResult.new(
          valid: true, event_type: "rejected",
          provider: @provider_type, payload: payload
        )
      end

      def handle_failed(payload)
        message_id = extract_message_id(payload, "failed")
        return no_message_id("failed") unless message_id

        delivery = find_delivery_any(message_id)
        return delivery_not_found(message_id) unless delivery

        delivery.mark_failed!(reason: payload["error"] || "Provider failure")
        delivery.email_message&.mark_failed!(reason: payload["error"] || "Provider failure")

        WebhookValidator::ValidationResult.new(
          valid: true, event_type: "failed",
          provider: @provider_type, payload: payload
        )
      end

      def handle_sent(payload)
        message_id = extract_message_id(payload, "sent")
        return no_message_id("sent") unless message_id

        delivery = find_delivery_any(message_id)
        return delivery_not_found(message_id) unless delivery

        EventPublisher.publish(
          event_type: "email.sent",
          organization_id: delivery.organization_id,
          payload: {
            email_id: delivery.email_message_id,
            delivery_id: delivery.id,
            provider: @provider_type,
            provider_message_id: message_id
          }
        )

        WebhookValidator::ValidationResult.new(
          valid: true, event_type: "sent",
          provider: @provider_type, payload: payload
        )
      end

      def extract_message_id(payload, event_type)
        case @provider_type
        when "ses"
          payload.dig("mail", "messageId") ||
            payload.dig("delivery", "recipients", 0) ||
            payload.dig("bounce", "bouncedRecipients", 0, "emailAddress")
        when "sendgrid"
          payload["sg_message_id"] || payload["smtp-id"]
        when "mailgun"
          payload.dig("message", "headers", "message-id") ||
            payload["recipient"] || payload["Message-Id"]
        when "postmark"
          payload["MessageID"] || payload["Recipient"]
        when "smtp"
          payload["message_id"]
        else
          payload["message_id"] || payload["id"]
        end
      end

      def extract_bounce_type(payload)
        case @provider_type
        when "ses"    then payload.dig("bounce", "bounceType")
        when "sendgrid" then payload["type"]
        when "mailgun"  then payload["notification"] || "permanent"
        when "postmark" then payload.dig("Bounce", "Type")
        else "permanent"
        end
      end

      def find_delivery(message_id)
        Delivery.find_by(provider_message_id: message_id)
      end

      def find_delivery_any(message_id)
        find_delivery(message_id) ||
          Delivery.find_by(provider_message_id: extract_short_id(message_id))
      end

      def extract_short_id(message_id)
        message_id.to_s.split("@").first
      end

      def no_message_id(event_type)
        WebhookValidator::ValidationResult.new(
          valid: false, error: "Could not extract message_id for #{event_type}"
        )
      end

      def delivery_not_found(message_id)
        WebhookValidator::ValidationResult.new(
          valid: false, error: "Delivery not found for message_id: #{message_id}"
        )
      end

      def already_processed(message_id)
        WebhookValidator::ValidationResult.new(
          valid: true, error: "Already processed for message_id: #{message_id}"
        )
      end
    end
  end
end
