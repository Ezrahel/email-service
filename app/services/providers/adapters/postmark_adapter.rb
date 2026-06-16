module Providers
  module Adapters
    class PostmarkAdapter < ProviderAdapter
      def send_email(email_message)
        result, duration = with_timing do
          payload = PostmarkSerializer.serialize(email_message, tracking_settings: tracking_settings)
          response = transport.post("/email", body: payload)

          if response.success?
            message_id = response.parsed_body.dig("MessageID")
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
            Messages: email_messages.map { |msg| PostmarkSerializer.serialize(msg, tracking_settings: tracking_settings) }
          }
          response = transport.post("/email/batch", body: payload)

          if response.success?
            message_ids = (response.parsed_body["Responses"] || []).map { |r| r["MessageID"] }
            Providers::ProviderResponse.delivered(message_id: message_ids.join(","), duration_ms: duration)
          else
            normalize_error(response)
          end
        end

        result
      end

      def cancel_delivery(provider_message_id)
        Providers::ProviderResponse.failed(error_message: "Postmark does not support cancellation", error_code: "UNSUPPORTED")
      end

      def check_status(provider_message_id)
        response = transport.get("/messages/outbound/#{provider_message_id}/details")
        return Providers::ProviderResponse.failed(error_message: "Not found", error_code: "NOT_FOUND") unless response.success?

        normalize_status(response)
      end

      def health_check
        response = transport.get("/server")
        { healthy: response.success?, latency_ms: response.duration_ms }
      rescue StandardError => e
        { healthy: false, error: e.message }
      end

      def validate_domain(domain)
        response = transport.get("/domains")
        return { verified: false, status: "NOT_FOUND" } unless response.success?

        domains = response.parsed_body["Domains"] || []
        matched = domains.find { |d| d["Name"] == domain }
        { verified: matched&.dig("SPFVerified") == true && matched&.dig("DKIMVerified") == true, status: matched&.dig("State") }
      end

      def estimate_cost(email_message)
        { amount: 0.001, currency: "USD" }
      end

      def supports_batch?
        true
      end

      private

      def build_transport
        Providers::Transport::PostmarkTransport.new(provider_config)
      end

      def tracking_settings
        config = provider_config.settings || {}
        {
          open_tracking: config.dig("tracking", "open").nil? || config.dig("tracking", "open"),
          click_tracking: config.dig("tracking", "click").nil? || config.dig("tracking", "click"),
          track_opens: config.dig("tracking", "open").nil? ? true : config.dig("tracking", "open"),
          track_links: config.dig("tracking", "click").nil? ? "HtmlOnly" : (config.dig("tracking", "click") ? "HtmlOnly" : "None")
        }
      end

      def normalize_error(response)
        body = response.parsed_body
        message = body.dig("Message") || body.dig("ErrorCode").to_s || "Unknown error"

        code_map = {
          401 => "AUTH_ERROR",
          403 => "AUTH_ERROR",
          422 => "INVALID_REQUEST",
          429 => "RATE_LIMIT"
        }

        error_code = code_map[response.status_code] || "HTTP_#{response.status_code}"

        if response.rate_limited?
          Providers::ProviderResponse.failed(error_message: message, error_code: "RATE_LIMIT", retryable: true)
        elsif response.status_code == 401 || response.status_code == 403
          Providers::ProviderResponse.rejected(error_message: message, error_code: "AUTH_ERROR")
        elsif response.status_code == 422
          Providers::ProviderResponse.rejected(error_message: message, error_code: "INVALID_REQUEST")
        else
          Providers::ProviderResponse.failed(error_message: message, error_code: error_code, retryable: response.server_error?)
        end
      end

      def normalize_status(response)
        msg = response.parsed_body
        status = msg.dig("Status")
        case status
        when "Sent", "Delivered" then Providers::ProviderResponse.delivered(message_id: msg["MessageID"])
        when "Bounced" then Providers::ProviderResponse.bounced(error_message: msg.dig("Bounce", "Description"), error_code: msg.dig("Bounce", "Type"))
        when "Failed"  then Providers::ProviderResponse.failed(error_message: msg.dig("MessageEvent", "Details"), error_code: "FAILED")
        else Providers::ProviderResponse.failed(error_message: "Status: #{status}", error_code: "UNKNOWN")
        end
      end
    end
  end
end
