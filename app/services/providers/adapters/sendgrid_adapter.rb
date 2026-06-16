module Providers
  module Adapters
    class SendgridAdapter < ProviderAdapter
      def send_email(email_message)
        result, duration = with_timing do
          payload = SendgridSerializer.serialize(email_message, tracking_settings: tracking_settings)
          response = transport.post("/v3/mail/send", body: payload)

          if response.success?
            message_id = extract_message_id(response)
            Providers::ProviderResponse.delivered(message_id: message_id, duration_ms: duration)
          else
            normalize_error(response)
          end
        end

        result
      end

      def send_batch(email_messages)
        result, duration = with_timing do
          payload = {
            messages: email_messages.map { |msg| SendgridSerializer.serialize(msg, tracking_settings: tracking_settings) }
          }
          response = transport.post("/v3/mail/send", body: payload)

          if response.success?
            message_ids = email_messages.map { extract_message_id(response) }
            Providers::ProviderResponse.delivered(message_id: message_ids.join(","), duration_ms: duration)
          else
            normalize_error(response)
          end
        end

        result
      end

      def cancel_delivery(provider_message_id)
        transport.delete("/v3/user/scheduled_sends", params: { batch_id: provider_message_id })
        Providers::ProviderResponse.delivered(message_id: provider_message_id)
      rescue Providers::Errors::ProviderError => e
        Providers::ProviderResponse.failed(error_message: e.message, error_code: "CANCEL_FAILED")
      end

      def check_status(provider_message_id)
        response = transport.get("/v3/messages/#{provider_message_id}")
        return Providers::ProviderResponse.failed(error_message: "Not found", error_code: "NOT_FOUND") unless response.success?

        normalize_status(response)
      end

      def health_check
        response = transport.get("/v3/scopes")
        { healthy: response.success?, latency_ms: response.duration_ms }
      rescue StandardError => e
        { healthy: false, error: e.message }
      end

      def validate_domain(domain)
        response = transport.get("/v3/whitelabel/domains", params: { domain: domain })
        return { verified: false, status: "NOT_FOUND" } unless response.success?

        results = response.parsed_body["results"] || []
        matched = results.find { |r| r["domain"] == domain }
        { verified: matched&.dig("valid") == true, status: matched&.dig("valid") ? "verified" : "unverified" }
      end

      def estimate_cost(email_message)
        { amount: 0.001, currency: "USD" }
      end

      def supports_batch?
        true
      end

      def supports_templates?
        true
      end

      private

      def build_transport
        Providers::Transport::SendgridTransport.new(provider_config)
      end

      def tracking_settings
        config = provider_config.settings || {}
        {
          open_tracking: config.dig("tracking", "open").nil? || config.dig("tracking", "open"),
          click_tracking: config.dig("tracking", "click").nil? || config.dig("tracking", "click"),
          subscription_tracking: config.dig("tracking", "subscription") || false,
          sandbox_mode: config["sandbox_mode"] || false
        }
      end

      def extract_message_id(response)
        response.headers["x-message-id"]&.first ||
          response.parsed_body.dig("message_id") ||
          SecureRandom.uuid
      end

      def normalize_error(response)
        body = response.parsed_body
        errors = body["errors"] || []
        message = errors.map { |e| e["message"] }.join("; ")
        code = errors.first&.dig("field") || "API_ERROR"

        if response.rate_limited?
          Providers::ProviderResponse.failed(error_message: message || "Rate limited", error_code: "RATE_LIMIT", retryable: true)
        elsif response.status_code == 401 || response.status_code == 403
          Providers::ProviderResponse.rejected(error_message: message || "Auth failed", error_code: "AUTH_ERROR")
        elsif response.status_code == 400
          Providers::ProviderResponse.rejected(error_message: message || "Bad request", error_code: code)
        else
          Providers::ProviderResponse.failed(error_message: message || "Unknown error", error_code: "HTTP_#{response.status_code}", retryable: response.server_error?)
        end
      end

      def normalize_status(response)
        event = response.parsed_body.dig("events", -1) || {}
        case event["event"]
        when "delivered" then Providers::ProviderResponse.delivered(message_id: event["sg_message_id"])
        when "bounce", "bounced" then Providers::ProviderResponse.bounced(error_message: event["reason"], error_code: event["type"])
        when "dropped" then Providers::ProviderResponse.rejected(error_message: event["reason"], error_code: "DROPPED")
        when "open"    then Providers::ProviderResponse.delivered(message_id: event["sg_message_id"])
        else Providers::ProviderResponse.failed(error_message: "Status: #{event['event']}", error_code: "UNKNOWN")
        end
      end
    end
  end
end
