module Providers
  module Transport
    class AwsSesTransport
      attr_reader :provider_config

      def initialize(provider_config)
        @provider_config = provider_config
        @client = build_client
      end

      def send_raw_email(source:, destinations:, raw_message:, tags: [], configuration_set: nil)
        params = {
          source: source,
          destinations: destinations,
          raw_message: { data: raw_message }
        }
        params[:configuration_set_name] = configuration_set if configuration_set

        if tags.any?
          params[:email_tags] = tags.map { |t| { name: "tag", value: t.to_s } }
        end

        @client.send_email(params)
      end

      def send_bulk_email(entries:, configuration_set: nil)
        params = { bulk_email_entries: entries }
        params[:configuration_set_name] = configuration_set if configuration_set
        @client.send_bulk_email(params)
      end

      def cancel_sending(message_id)
        @client.cancel_email_sending({ message_id: message_id })
      end

      def get_message_insights(message_id:)
        @client.get_message_insights({ message_id: message_id })
      end

      def send_quota
        @client.get_send_quota
      end

      def get_identity_verification_attributes(identities:)
        @client.get_identity_verification_attributes({ identities: identities })
      end

      private

      def build_client
        creds = provider_config.credentials
        settings = provider_config.settings || {}

        Aws::SESV2::Client.new(
          region: creds["region"] || settings["region"] || "us-east-1",
          access_key_id: creds["access_key_id"],
          secret_access_key: creds["secret_access_key"],
          http_open_timeout: settings["open_timeout"] || 5,
          http_read_timeout: settings["read_timeout"] || 10,
          retry_limit: settings["retry_limit"] || 3
        )
      end
    end
  end
end
