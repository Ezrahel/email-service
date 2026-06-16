module EmailPipeline
  class MimeBuilder < ApplicationService
    MULTIPART_BOUNDARY = "email_service_boundary_#{SecureRandom.hex(8)}".freeze

    def initialize(email:)
      @email = email
    end

    def call
      build_mime_message
    end

    def build_mime_message
      mail = Mail.new
      mail.from = @email.from_address
      mail.to = @email.to_address
      mail.subject = @email.subject
      mail.message_id = @email.message_id || "<#{SecureRandom.uuid}@#{extract_domain}>"
      mail.date = Time.current

      if @email.reply_to.present?
        mail.reply_to = @email.reply_to
      end

      add_headers(mail)
      add_content(mail)
      add_attachments(mail)

      mail.to_s
    end

    private

    def add_headers(mail)
      mail.header["X-Mailer"] = "EmailService/1.0"
      mail.header["X-Entity-Ref-ID"] = @email.id

      if @email.headers.is_a?(Hash)
        @email.headers.each do |key, value|
          mail.header[key] = value.to_s
        end
      end
    end

    def add_content(mail)
      if @email.html_body.present? && @email.text_body.present?
        mail.content_type = "multipart/alternative; boundary=#{MULTIPART_BOUNDARY}"

        part_text = Mail::Part.new do
          content_type "text/plain; charset=UTF-8"
          body @email.text_body
        end

        part_html = Mail::Part.new do
          content_type "text/html; charset=UTF-8"
          body wrap_html(@email.html_body)
        end

        mail.parts << part_text
        mail.parts << part_html
      elsif @email.html_body.present?
        mail.content_type = "text/html; charset=UTF-8"
        mail.body = wrap_html(@email.html_body)
      else
        mail.content_type = "text/plain; charset=UTF-8"
        mail.body = @email.text_body
      end
    end

    def add_attachments(mail)
      @email.attachments.each do |attachment|
        mail.add_file(filename: attachment.filename, content: fetch_from_s3(attachment))
        mail.attachments.last.content_type = attachment.content_type
      end
    rescue StandardError => e
      Rails.logger.warn "Failed to attach file for email #{@email.id}: #{e.message}"
    end

    def fetch_from_s3(attachment)
      # Phase 6: implement S3 fetch
      ""
    end

    def wrap_html(html)
      <<~HTML
        <!DOCTYPE html>
        <html><head><meta charset="utf-8"></head><body>#{html}</body></html>
      HTML
    end

    def extract_domain
      @email.from_address.to_s.split("@").last || "email-service.local"
    end
  end
end
