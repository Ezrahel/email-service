module Providers
  module Transport
    class MailgunTransport < TransportClient
      BASE_URL = "https://api.mailgun.net"

      private

      def build_base_url
        provider_config.settings&.dig("endpoint") || BASE_URL
      end

      def make_request(method, path, body: nil, params: {}, headers: {})
        api_key = provider_config.credentials["api_key"]
        raise Providers::Errors::AuthenticationError, "Mailgun API key missing" if api_key.blank?

        username = provider_config.credentials["username"] || "api"
        auth = Base64.strict_encode64("#{username}:#{api_key}")
        headers["Authorization"] = "Basic #{auth}"
        super
      end
    end
  end
end
