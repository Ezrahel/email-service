module Providers
  module Adapters
    class MailgunAdapter < ProviderAdapter
      def send_email(email_message)
        result, duration = with_timing do
          payload = MailgunSerializer.serialize(email_message, tracking_settings: tracking_settings)
          response = transport.post("/v3/#{mailgun_domain}/messages", body: payload, headers: form_headers)

          if response.success?
            message_id = response.parsed_body.dig("id")&.gsub(/[<>]/, "")
            Providers::ProviderResponse.delivered(message_id: message_id, duration_ms: duration)
          else
            normalize_error(response)
          end
        end

        result
      end

      def cancel_delivery(provider_message_id)
        transport.delete("/v3/#{mailgun_domain}/messages/#{provider_message_id}")
        Providers::ProviderResponse.delivered(message_id: provider_message_id)
      rescue Providers::Errors::ProviderError
        Providers::ProviderResponse.failed(error_message: "Cancel not supported", error_code: "CANCEL_FAILED")
      end

      def check_status(provider_message_id)
        response = transport.get("/v3/#{mailgun_domain}/events", params: { "message-id" => provider_message_id })
        return Providers::ProviderResponse.failed(error_message: "Not found", error_code: "NOT_FOUND") unless response.success?

        normalize_status(response)
      end

      def health_check
        response = transport.get("/v3/#{mailgun_domain}/stats", params: { event: ["delivered", "failed"], duration: "1h" })
        { healthy: response.success?, latency_ms: response.duration_ms }
      rescue StandardError => e
        { healthy: false, error: e.message }
      end

      def validate_domain(domain)
        response = transport.get("/v3/domains/#{domain}")
        return { verified: false, status: "NOT_FOUND" } unless response.success?

        domain_data = response.parsed_body.dig("domain") || {}
        state = domain_data["state"]
        { verified: state == "active", status: state }
      end

      def estimate_cost(email_message)
        { amount: 0.0008, currency: "USD" }
      end

      def supports_batch?
        false
      end

      private

      def build_transport
        Providers::Transport::MailgunTransport.new(provider_config)
      end

      def mailgun_domain
        provider_config.settings&.dig("domain") || provider_config.credentials["domain"] || "mg.example.com"
      end

      def form_headers
        { "Content-Type" => "application/x-www-form-urlencoded" }
      end

      def tracking_settings
        config = provider_config.settings || {}
        {
          open_tracking: config.dig("tracking", "open").nil? || config.dig("tracking", "open"),
          click_tracking: config.dig("tracking", "click").nil? || config.dig("tracking", "click"),
          subscription_tracking: config.dig("tracking", "subscription") || false
        }
      end

      def normalize_error(response)
        body = response.parsed_body
        message = body.dig("message") || body.dig("error") || "Unknown error"

        if response.rate_limited?
          retry_after = response.retry_after
          Providers::ProviderResponse.failed(error_message: message, error_code: "RATE_LIMIT", retryable: true)
        elsif response.status_code == 401
          Providers::ProviderResponse.rejected(error_message: message, error_code: "AUTH_ERROR")
        elsif response.status_code == 400
          Providers::ProviderResponse.rejected(error_message: message, error_code: "INVALID_REQUEST")
        else
          Providers::ProviderResponse.failed(error_message: message, error_code: "HTTP_#{response.status_code}", retryable: response.server_error?)
        end
      end

      def normalize_status(response)
        items = response.parsed_body.dig("items") || []
        event = items.first || {}
        case event["event"]
        when "delivered" then Providers::ProviderResponse.delivered(message_id: event.dig("message", "headers", "message-id"))
        when "failed"    then Providers::ProviderResponse.failed(error_message: event.dig("delivery-status", "message"), error_code: event.dig("reason")&.upcase, retryable: false)
        when "bounced"   then Providers::ProviderResponse.bounced(error_message: event.dig("delivery-status", "message"), error_code: "BOUNCE")
        when "opened"    then Providers::ProviderResponse.delivered(message_id: event.dig("message", "headers", "message-id"))
        else Providers::ProviderResponse.failed(error_message: "Status: #{event['event']}", error_code: "UNKNOWN")
        end
      end
    end
  end
end
