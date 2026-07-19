module Providers
  module Transport
    class SmtpTransport
      attr_reader :provider_config

      def initialize(provider_config)
        @provider_config = provider_config
      end

      def deliver(mail_string, from:, to:)
        smtp = build_smtp
        smtp.start
        smtp.send_message(mail_string, from, to)
        true
      ensure
        smtp&.finish rescue nil
      end

      private

      def build_smtp
        creds = provider_config.credentials
        settings = provider_config.settings || {}

        smtp = Net::SMTP.new(
          creds["host"] || settings["host"] || "localhost",
          creds["port"] || settings["port"] || 587
        )

        if creds["tls"] != false
          smtp.enable_starttls_auto
        end

        smtp.open_timeout = settings["open_timeout"] || 10
        smtp.read_timeout = settings["read_timeout"] || 10

        @smtp_args = {
          user: creds["username"] || creds["user"],
          password: creds["password"],
          domain: creds["domain"] || creds["helo_domain"] || "localhost"
        }

        smtp
      end
    end
  end
end
