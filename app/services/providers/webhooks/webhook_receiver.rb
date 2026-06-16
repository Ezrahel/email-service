module Providers
  module Webhooks
    class WebhookReceiver
      DuplicateEntry = Class.new(StandardError)

      def initialize(provider_type, request)
        @provider_type = provider_type
        @request = request
        @idempotency_key = build_idempotency_key
      end

      def receive
        return duplicate_response if duplicate?

        processor = WebhookProcessor.new(provider_type: @provider_type)
        result = processor.process(@request)

        if result.valid?
          record_idempotency
        end

        result
      end

      private

      def duplicate?
        return false unless @idempotency_key

        REDIS_POOL.with do |conn|
          conn.exists?("webhook:dedup:#{@idempotency_key}")
        end
      end

      def duplicate_response
        WebhookValidator::ValidationResult.new(
          valid: false,
          error: "Duplicate webhook event",
          event_type: "duplicate"
        )
      end

      def record_idempotency
        return unless @idempotency_key

        REDIS_POOL.with do |conn|
          conn.setex("webhook:dedup:#{@idempotency_key}", 300, "1")
        end
      end

      def build_idempotency_key
        case @provider_type
        when "ses"
          notification = JSON.parse(@request.body.read) rescue {}
          @request.body.rewind
          notification.dig("MessageId") || notification.dig("mail", "messageId")
        when "sendgrid"
          @request.headers["X-Twilio-Email-Webhook-Id"] ||
            Digest::SHA256.hexdigest(@request.body.read.tap { @request.body.rewind })
        when "mailgun"
          @request.params["timestamp"].to_s + @request.params["token"].to_s
        when "postmark"
          payload = JSON.parse(@request.body.read) rescue {}
          @request.body.rewind
          payload["MessageID"] || Digest::SHA256.hexdigest(@request.body.read.tap { @request.body.rewind })
        else
          Digest::SHA256.hexdigest(@request.body.read.tap { @request.body.rewind })
        end
      end
    end
  end
end
