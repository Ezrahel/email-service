module Providers
  module Transport
    class PostmarkTransport < TransportClient
      BASE_URL = "https://api.postmarkapp.com"

      private

      def build_base_url
        provider_config.settings&.dig("endpoint") || BASE_URL
      end

      def make_request(method, path, body: nil, params: {}, headers: {})
        api_token = provider_config.credentials["api_token"]
        raise Providers::Errors::AuthenticationError, "Postmark API token missing" if api_token.blank?

        headers["X-Postmark-Server-Token"] = api_token
        super
      end
    end
  end
end
