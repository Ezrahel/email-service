module Providers
  module Adapters
    class PostmarkSerializer
      class << self
        def serialize(email_message, tracking_settings: {})
          payload = {
            From: email_message.from_address,
            To: email_message.to_address,
            Subject: email_message.subject,
            HtmlBody: email_message.html_body,
            TextBody: email_message.text_body,
            Headers: build_headers(email_message),
            Tag: email_message.tags&.first,
            TrackOpens: tracking_settings[:track_opens],
            TrackLinks: tracking_settings[:track_links]
          }

          payload[:Cc] = email_message.cc_address if email_message.respond_to?(:cc_address) && email_message.cc_address.present?
          payload[:Bcc] = email_message.bcc_address if email_message.respond_to?(:bcc_address) && email_message.bcc_address.present?
          payload[:ReplyTo] = email_message.reply_to if email_message.respond_to?(:reply_to) && email_message.reply_to.present?

          if email_message.attachments.any?
            payload[:Attachments] = email_message.attachments.map do |att|
              {
                Name: att.filename,
                Content: Base64.strict_encode64(att.file_data),
                ContentType: att.content_type,
                ContentID: att.content_id
              }
            end
          end

          if email_message.respond_to?(:metadata) && email_message.metadata.present?
            payload[:Metadata] = email_message.metadata
          end

          payload
        end

        private

        def build_headers(email_message)
          headers = []
          if email_message.headers.present?
            email_message.headers.each { |k, v| headers << { Name: k, Value: v } }
          end
          headers
        end
      end
    end
  end
end
