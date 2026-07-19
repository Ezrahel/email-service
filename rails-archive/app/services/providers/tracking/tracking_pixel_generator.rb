module Providers
  module Tracking
    class TrackingPixelGenerator
      PIXEL_GIF = [
        0x47, 0x49, 0x46, 0x38, 0x39, 0x61,
        0x01, 0x00, 0x01, 0x00,
        0x80, 0x00, 0x00,
        0xff, 0xff, 0xff,
        0x00, 0x00, 0x00,
        0x21, 0xf9, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x2c, 0x00, 0x00, 0x00, 0x00,
        0x01, 0x00, 0x01, 0x00,
        0x00, 0x02, 0x02, 0x44, 0x01, 0x00, 0x3b
      ].pack("C*").freeze

      PIXEL_CONTENT_TYPE = "image/gif".freeze

      class << self
        def pixel_data
          PIXEL_GIF
        end

        def content_type
          PIXEL_CONTENT_TYPE
        end

        def tracking_url(email_message_id:, organization_id:, base_url: nil)
          base = base_url || ENV.fetch("TRACKING_BASE_URL", "https://t.example.com")
          token = generate_token(email_message_id, organization_id)

          "#{base}/t/o/#{token}.gif"
        end

        def verify_token(token)
          decoded = decode_token(token)
          return nil unless decoded

          email_message = EmailMessage.find_by(id: decoded[:email_message_id])
          return nil unless email_message
          return nil unless email_message.organization_id == decoded[:organization_id]

          email_message
        rescue ActiveSupport::MessageVerifier::InvalidSignature
          nil
        end

        private

        def generate_token(email_message_id, organization_id)
          verifier.generate({
            email_message_id: email_message_id,
            organization_id: organization_id,
            exp: 30.days.from_now.to_i
          })
        end

        def decode_token(token)
          data = verifier.verify(token)
          return nil if data[:exp] < Time.current.to_i
          data
        rescue ActiveSupport::MessageVerifier::InvalidSignature
          nil
        end

        def verifier
          Rails.application.message_verifier("tracking_pixel")
        end
      end
    end
  end
end
