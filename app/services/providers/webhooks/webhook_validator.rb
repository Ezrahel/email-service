module Providers
  module Webhooks
    class WebhookValidator
      class ValidationResult
        attr_reader :valid, :event_type, :provider, :payload, :error

        def initialize(valid:, event_type: nil, provider: nil, payload: nil, error: nil)
          @valid = valid
          @event_type = event_type
          @provider = provider
          @payload = payload
          @error = error
        end

        def valid?
          @valid
        end
      end

      SUPPORTED_PROVIDERS = %w[ses sendgrid mailgun postmark].freeze

      def initialize(provider_type)
        @provider_type = provider_type.to_s
      end

      def validate(request)
        case @provider_type
        when "ses"      then validate_ses(request)
        when "sendgrid" then validate_sendgrid(request)
        when "mailgun"  then validate_mailgun(request)
        when "postmark" then validate_postmark(request)
        else
          ValidationResult.new(valid: false, error: "Unsupported provider: #{@provider_type}")
        end
      end

      private

      def validate_ses(request)
        body = request.body.read
        signature = request.headers["X-SES-Signature"]
        cert_url = request.headers["X-SES-Certificate-Url"]

        unless signature && cert_url
          return ValidationResult.new(valid: false, error: "Missing SES signature headers")
        end

        verifier = Aws::SESV2::Types::SNSMessageVerifier.new
        verified = verifier.verify?(raw_message: body)

        unless verified
          return ValidationResult.new(valid: false, error: "Invalid SES signature")
        end

        notification = JSON.parse(body)
        message = JSON.parse(notification["Message"]) rescue notification
        event_type = map_ses_event(message["notificationType"])

        ValidationResult.new(
          valid: true,
          event_type: event_type,
          provider: "ses",
          payload: message
        )
      rescue JSON::ParserError => e
        ValidationResult.new(valid: false, error: "Invalid JSON: #{e.message}")
      end

      def validate_sendgrid(request)
        signature = request.headers["X-Twilio-Email-Webhook-Signature"]
        timestamp = request.headers["X-Twilio-Email-Webhook-Timestamp"]
        body = request.body.read

        unless signature && timestamp
          return ValidationResult.new(valid: false, error: "Missing SendGrid signature headers")
        end

        verified = verify_sendgrid_signature(signature, timestamp, body)
        unless verified
          return ValidationResult.new(valid: false, error: "Invalid SendGrid signature")
        end

        events = JSON.parse(body)
        event = events.is_a?(Array) ? events.first : events

        ValidationResult.new(
          valid: true,
          event_type: map_sendgrid_event(event["event"]),
          provider: "sendgrid",
          payload: event
        )
      rescue JSON::ParserError => e
        ValidationResult.new(valid: false, error: "Invalid JSON: #{e.message}")
      end

      def validate_mailgun(request)
        token = request.params["token"]
        timestamp = request.params["timestamp"]
        signature = request.params["signature"]

        unless token && timestamp && signature
          body = request.body.read
          params = JSON.parse(body) rescue {}
          token = params["token"] || params["signature"]["token"] rescue nil
          timestamp = params["timestamp"] || params["signature"]["timestamp"] rescue nil
          signature = params["signature"] || params["signature"]["signature"] rescue nil
        end

        unless token && timestamp && signature
          return ValidationResult.new(valid: false, error: "Missing Mailgun signature params")
        end

        verified = verify_mailgun_signature(token, timestamp, signature)
        unless verified
          return ValidationResult.new(valid: false, error: "Invalid Mailgun signature")
        end

        ValidationResult.new(
          valid: true,
          event_type: map_mailgun_event(request.params["event"]),
          provider: "mailgun",
          payload: request.params.to_h
        )
      end

      def validate_postmark(request)
        signature = request.headers["X-Postmark-Signature"]
        body = request.body.read

        unless signature
          return ValidationResult.new(valid: false, error: "Missing Postmark signature header")
        end

        payload = JSON.parse(body) rescue {}

        ValidationResult.new(
          valid: true,
          event_type: map_postmark_event(payload["RecordType"]),
          provider: "postmark",
          payload: payload
        )
      rescue JSON::ParserError => e
        ValidationResult.new(valid: false, error: "Invalid JSON: #{e.message}")
      end

      def verify_sendgrid_signature(signature, timestamp, body)
        key = ENV["SENDGRID_WEBHOOK_VERIFICATION_KEY"] || ""
        payload = "#{timestamp}#{body}"
        expected = OpenSSL::HMAC.hexdigest("SHA256", key, payload)
        ActiveSupport::SecurityUtils.secure_compare(signature.to_s, expected)
      rescue OpenSSL::HMACError
        false
      end

      def verify_mailgun_signature(token, timestamp, signature)
        api_key = ENV["MAILGUN_API_KEY"] || ""
        data = "#{timestamp}#{token}"
        expected = OpenSSL::HMAC.hexdigest("SHA256", api_key, data)
        ActiveSupport::SecurityUtils.secure_compare(signature.to_s, expected)
      rescue OpenSSL::HMACError
        false
      end

      def map_ses_event(type)
        case type
        when "Delivery"    then "delivered"
        when "Bounce"      then "bounced"
        when "Complaint"   then "complained"
        when "Open"        then "opened"
        when "Click"       then "clicked"
        when "Reject"      then "rejected"
        when "Send"        then "sent"
        else "unknown_#{type}"
        end
      end

      def map_sendgrid_event(event)
        case event
        when "delivered", "processed"  then "delivered"
        when "bounce", "bounced"       then "bounced"
        when "dropped"                 then "rejected"
        when "open", "click"          then event
        when "spamreport"             then "complained"
        when "unsubscribe"            then "unsubscribed"
        when "group_unsubscribe"      then "unsubscribed"
        when "group_resubscribe"      then "resubscribed"
        else "unknown_#{event}"
        end
      end

      def map_mailgun_event(event)
        case event
        when "delivered"  then "delivered"
        when "failed"     then "failed"
        when "bounced"    then "bounced"
        when "opened"     then "opened"
        when "clicked"    then "clicked"
        when "complained" then "complained"
        when "unsubscribed" then "unsubscribed"
        when "rejected"   then "rejected"
        else "unknown_#{event}"
        end
      end

      def map_postmark_event(type)
        case type
        when "Delivery"         then "delivered"
        when "Bounce"           then "bounced"
        when "SpamComplaint"    then "complained"
        when "Open"             then "opened"
        when "Click"            then "clicked"
        when "SubscriptionChange" then "unsubscribed"
        else "unknown_#{type}"
        end
      end
    end
  end
end
