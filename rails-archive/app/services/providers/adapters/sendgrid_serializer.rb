module Providers
  module Adapters
    class SendgridSerializer
      class << self
        def serialize(email_message, tracking_settings: {})
          payload = {
            personalizations: build_personalizations(email_message),
            from: build_email(email_message.from_address, email_message.from_name),
            subject: email_message.subject,
            content: build_content(email_message),
            headers: email_message.headers || {},
            categories: email_message.tags || [],
            tracking_settings: build_tracking(tracking_settings)
          }

          payload[:reply_to] = build_email(email_message.reply_to) if email_message.respond_to?(:reply_to) && email_message.reply_to.present?
          payload[:template_id] = email_message.template&.provider_template_id if email_message.template&.provider_template_id.present?
          payload[:attachments] = build_attachments(email_message.attachments) if email_message.attachments.any?

          payload
        end

        private

        def build_personalizations(email_message)
          personalization = {
            to: email_message.to_address.split(",").map { |addr| build_email(addr.strip) },
            subject: email_message.subject
          }

          if email_message.respond_to?(:cc_address) && email_message.cc_address.present?
            personalization[:cc] = email_message.cc_address.split(",").map { |addr| build_email(addr.strip) }
          end

          if email_message.respond_to?(:bcc_address) && email_message.bcc_address.present?
            personalization[:bcc] = email_message.bcc_address.split(",").map { |addr| build_email(addr.strip) }
          end

          if email_message.respond_to?(:substitutions) && email_message.substitutions.present?
            personalization[:substitutions] = email_message.substitutions
          end

          if email_message.respond_to?(:custom_args) && email_message.custom_args.present?
            personalization[:custom_args] = email_message.custom_args
          end

          [personalization]
        end

        def build_email(address, name = nil)
          entry = { email: address }
          entry[:name] = name if name.present?
          entry
        end

        def build_content(email_message)
          content = []
          content << { type: "text/plain", value: email_message.text_body } if email_message.text_body.present?
          content << { type: "text/html", value: email_message.html_body } if email_message.html_body.present?
          content
        end

        def build_tracking(settings)
          {
            open_tracking: { enable: settings[:open_tracking] },
            click_tracking: { enable: settings[:click_tracking], enable_text: settings[:click_tracking] },
            subscription_tracking: { enable: settings[:subscription_tracking] },
            sandbox_mode: { enable: settings[:sandbox_mode] }
          }
        end

        def build_attachments(attachments)
          attachments.map do |att|
            {
              content: Base64.strict_encode64(att.file_data),
              filename: att.filename,
              type: att.content_type,
              disposition: att.disposition || "attachment"
            }
          end
        end
      end
    end
  end
end
