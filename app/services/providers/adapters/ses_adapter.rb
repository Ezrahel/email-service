module Providers
  module Adapters
    class SesAdapter < ProviderAdapter
      def send_email(email_message)
        result, duration = with_timing do
          response = transport.send_raw_email(
            source: email_message.from_address,
            destinations: [email_message.to_address],
            raw_message: email_message.raw_source,
            tags: email_message.tags,
            configuration_set: provider_config.settings&.dig("configuration_set")
          )
          normalize_response(response)
        end

        result.tap { |r| r.metadata[:duration_ms] = duration }
      rescue Aws::SESV2::Errors::MessageRejected => e
        Providers::ProviderResponse.rejected(error_message: e.message, error_code: "MESSAGE_REJECTED")
      rescue Aws::SESV2::Errors::LimitExceededException => e
        Providers::ProviderResponse.failed(error_message: e.message, error_code: "RATE_LIMIT", retryable: true)
      rescue Aws::SESV2::Errors::AccountSuspendedException => e
        Providers::ProviderResponse.rejected(error_message: e.message, error_code: "ACCOUNT_SUSPENDED")
      rescue Aws::SESV2::Errors::ServiceError => e
        Providers::ProviderResponse.failed(error_message: e.message, error_code: e.class.name.demodulize, retryable: e.retryable?)
      end

      def send_batch(email_messages)
        result, duration = with_timing do
          response = transport.send_bulk_email(
            entries: email_messages.map { |msg| build_bulk_entry(msg) },
            configuration_set: provider_config.settings&.dig("configuration_set")
          )
          normalize_bulk_response(response)
        end

        result.tap { |r| r.metadata[:duration_ms] = duration }
      rescue Aws::SESV2::Errors::ServiceError => e
        Providers::ProviderResponse.failed(error_message: e.message, error_code: e.class.name.demodulize, retryable: e.retryable?)
      end

      def cancel_delivery(provider_message_id)
        transport.cancel_sending(provider_message_id)
        Providers::ProviderResponse.delivered(message_id: provider_message_id)
      rescue Aws::SESV2::Errors::ServiceError => e
        Providers::ProviderResponse.failed(error_message: e.message, error_code: e.class.name.demodulize)
      end

      def check_status(provider_message_id)
        response = transport.get_message_insights(message_id: provider_message_id)
        normalize_status_response(response)
      rescue Aws::SESV2::Errors::NotFoundException
        Providers::ProviderResponse.failed(error_message: "Message not found", error_code: "NOT_FOUND")
      end

      def health_check
        transport.send_quota
        { healthy: true, latency_ms: 0 }
      rescue Aws::SESV2::Errors::ServiceError => e
        { healthy: false, error: e.message }
      end

      def validate_domain(domain)
        response = transport.get_identity_verification_attributes(identities: [domain])
        status = response.verification_attributes[domain]&.verification_status
        { verified: status == "Success", status: status }
      rescue Aws::SESV2::Errors::NotFoundException
        { verified: false, status: "NOT_FOUND" }
      end

      def estimate_cost(email_message)
        size_kb = email_message.raw_source.bytesize / 1024.0
        { amount: size_kb * 0.0001, currency: "USD" }
      end

      def supports_batch?
        true
      end

      def supports_cancel?
        true
      end

      def supports_templates?
        true
      end

      private

      def build_transport
        Providers::Transport::AwsSesTransport.new(provider_config)
      end

      def normalize_response(response)
        message_id = response.message_id
        Providers::ProviderResponse.delivered(message_id: message_id)
      end

      def normalize_bulk_response(response)
        message_ids = response.entries.map(&:message_id)
        Providers::ProviderResponse.delivered(message_id: message_ids.join(","))
      end

      def normalize_status_response(response)
        insights = response.insights&.first
        return Providers::ProviderResponse.failed(error_message: "No insights", error_code: "NOT_FOUND") unless insights

        status = insights.insights_events&.last&.type
        case status
        when "DELIVERY" then Providers::ProviderResponse.delivered(message_id: insights.message_id)
        when "BOUNCE"    then Providers::ProviderResponse.bounced(error_message: "Bounced", error_code: "BOUNCE")
        when "COMPLAINT" then Providers::ProviderResponse.rejected(error_message: "Complaint", error_code: "COMPLAINT")
        else Providers::ProviderResponse.failed(error_message: "Status: #{status}", error_code: status)
        end
      end

      def build_bulk_entry(email_message)
        {
          destination: { to_addresses: [email_message.to_address] },
          replacement_email_content: {
            raw: { data: email_message.raw_source }
          }
        }
      end
    end
  end
end
