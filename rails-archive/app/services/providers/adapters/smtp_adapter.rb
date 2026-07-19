module Providers
  module Adapters
    class SmtpAdapter < ProviderAdapter
      def send_email(email_message)
        result, duration = with_timing do
          mail = build_mail(email_message)
          deliver_mail(mail)
          message_id = mail.message_id
          Providers::ProviderResponse.delivered(message_id: message_id, duration_ms: duration)
        end

        result
      rescue Net::SMTPAuthenticationError => e
        Providers::ProviderResponse.rejected(error_message: e.message, error_code: "AUTH_ERROR")
      rescue Net::SMTPServerBusy => e
        Providers::ProviderResponse.failed(error_message: e.message, error_code: "SERVER_BUSY", retryable: true)
      rescue Net::SMTPFatalError => e
        Providers::ProviderResponse.rejected(error_message: e.message, error_code: "FATAL_ERROR")
      rescue Net::SMTPUnknownError => e
        Providers::ProviderResponse.failed(error_message: e.message, error_code: "UNKNOWN_ERROR", retryable: true)
      rescue Net::OpenTimeout, Net::ReadTimeout => e
        Providers::ProviderResponse.failed(error_message: e.message, error_code: "TIMEOUT", retryable: true)
      rescue StandardError => e
        Providers::ProviderResponse.failed(error_message: e.message, error_code: "SMTP_ERROR", retryable: true)
      end

      def cancel_delivery(provider_message_id)
        Providers::ProviderResponse.failed(error_message: "SMTP does not support cancellation", error_code: "UNSUPPORTED")
      end

      def check_status(provider_message_id)
        Providers::ProviderResponse.failed(error_message: "SMTP does not support status checks", error_code: "UNSUPPORTED")
      end

      def health_check
        smtp = build_smtp_connection
        smtp.open_timeout = 5
        smtp.read_timeout = 5
        smtp.start
        { healthy: true, latency_ms: 0 }
      rescue StandardError => e
        { healthy: false, error: e.message }
      ensure
        smtp&.finish rescue nil
      end

      def validate_domain(domain)
        { verified: true, status: "assumed" }
      end

      def estimate_cost(email_message)
        { amount: 0.0, currency: "USD" }
      end

      def supports_batch?
        false
      end

      def supports_cancel?
        false
      end

      def supports_status_check?
        false
      end

      def supports_tracking?
        false
      end

      private

      def build_transport
        Providers::Transport::SmtpTransport.new(provider_config)
      end

      def build_mail(email_message)
        mail = Mail.new
        mail.from = email_message.from_address
        mail.to = email_message.to_address
        mail.cc = email_message.cc_address if email_message.respond_to?(:cc_address) && email_message.cc_address.present?
        mail.bcc = email_message.bcc_address if email_message.respond_to?(:bcc_address) && email_message.bcc_address.present?
        mail.subject = email_message.subject
        mail.headers = email_message.headers if email_message.headers.present?
        mail.message_id = "<#{SecureRandom.uuid}@#{extract_domain(email_message.from_address)}>"

        if email_message.html_body.present?
          mail.html_part = build_html_part(email_message)
        end

        if email_message.text_body.present?
          mail.text_part = build_text_part(email_message)
        end

        if email_message.attachments.any?
          email_message.attachments.each do |attachment|
            mail.attachments[attachment.filename] = {
              mime_type: attachment.content_type,
              content: attachment.file_data
            }
          end
        end

        mail
      end

      def build_html_part(email_message)
        part = Mail::Part.new
        part.content_type = "text/html; charset=UTF-8"
        part.body = email_message.html_body
        part
      end

      def build_text_part(email_message)
        part = Mail::Part.new
        part.content_type = "text/plain; charset=UTF-8"
        part.body = email_message.text_body
        part
      end

      def deliver_mail(mail)
        smtp = build_smtp_connection
        smtp.start
        smtp.send_message(mail.to_s, mail.from.first, mail.destinations)
      ensure
        smtp&.finish rescue nil
      end

      def build_smtp_connection
        creds = provider_config.credentials
        settings = provider_config.settings || {}

        smtp = Net::SMTP.new(
          creds["host"] || settings["host"] || "localhost",
          creds["port"] || settings["port"] || 587
        )

        smtp.enable_starttls_auto if creds["tls"] != false
        smtp.open_timeout = settings["open_timeout"] || 10
        smtp.read_timeout = settings["read_timeout"] || 10

        @smtp_credentials = {
          user: creds["username"] || creds["user"],
          password: creds["password"],
          domain: creds["domain"] || creds["helo_domain"] || "localhost"
        }

        smtp
      end

      def extract_domain(from_address)
        from_address.to_s.split("@").last || "localhost"
      end
    end
  end
end
