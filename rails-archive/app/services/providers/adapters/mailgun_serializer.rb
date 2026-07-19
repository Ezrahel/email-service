module Providers
  module Adapters
    class MailgunSerializer
      class << self
        def serialize(email_message, tracking_settings: {})
          payload = {
            from: email_message.from_address,
            to: email_message.to_address,
            subject: email_message.subject,
            html: email_message.html_body,
            text: email_message.text_body
          }

          payload[:cc] = email_message.cc_address if email_message.respond_to?(:cc_address) && email_message.cc_address.present?
          payload[:bcc] = email_message.bcc_address if email_message.respond_to?(:bcc_address) && email_message.bcc_address.present?
          payload[:o:tracking] = tracking_settings[:open_tracking] ? "yes" : "no"
          payload[:o:tracking-clicks] = tracking_settings[:click_tracking] ? "yes" : "no"
          payload[:"h:Reply-To"] = email_message.reply_to if email_message.respond_to?(:reply_to) && email_message.reply_to.present?
          payload[:t] = email_message.template&.provider_template_id if email_message.template&.provider_template_id.present?

          if email_message.tags.present?
            email_message.tags.each_with_index { |tag, i| payload[:"o:tag-#{i + 1}"] = tag }
          end

          if email_message.respond_to?(:custom_variables) && email_message.custom_variables.present?
            email_message.custom_variables.each { |k, v| payload[:"v:#{k}"] = v }
          end

          if email_message.attachments.any?
            payload[:attachment] = email_message.attachments.map do |att|
              Faraday::UploadIO.new(StringIO.new(att.file_data), att.content_type, att.filename)
            end
          end

          payload
        end
      end
    end
  end
end
