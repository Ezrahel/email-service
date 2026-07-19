module Providers
  module Transport
    class SendgridTransport < TransportClient
      BASE_URL = "https://api.sendgrid.com"

      private

      def build_base_url
        provider_config.settings&.dig("endpoint") || BASE_URL
      end

      def build_http_client
        http = super
        http
      end

      def make_request(method, path, body: nil, params: {}, headers: {})
        api_key = provider_config.credentials["api_key"]
        raise Providers::Errors::AuthenticationError, "SendGrid API key missing" if api_key.blank?

        headers["Authorization"] = "Bearer #{api_key}"
        super
      end
    end
  end
end
