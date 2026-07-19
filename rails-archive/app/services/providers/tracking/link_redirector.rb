module Providers
  module Tracking
    class LinkRedirector
      class << self
        def wrap_links(html_body:, email_message_id:, organization_id:, base_url: nil)
          return html_body unless html_body.present?

          base = base_url || ENV.fetch("TRACKING_BASE_URL", "https://t.example.com")

          html_body.gsub(/href=["'](https?:\/\/[^"']+)["']/i) do |match|
            original_url = $1
            next match if internal_url?(original_url, base)
            next match if skip_url?(original_url)

            redirect_path = generate_redirect_path(original_url, email_message_id, organization_id)
            %(href="#{base}#{redirect_path}")
          end
        end

        def resolve_redirect(encoded_url)
          data = decode_redirect(encoded_url)
          return nil unless data
          return nil if data[:exp] < Time.current.to_i

          record_click(
            email_message_id: data[:email_message_id],
            organization_id: data[:organization_id],
            target_url: data[:target_url]
          )

          data[:target_url]
        end

        private

        def generate_redirect_path(original_url, email_message_id, organization_id)
          token = generate_token(original_url, email_message_id, organization_id)
          "/t/c/#{token}"
        end

        def generate_token(target_url, email_message_id, organization_id)
          verifier.generate({
            target_url: target_url,
            email_message_id: email_message_id,
            organization_id: organization_id,
            exp: 30.days.from_now.to_i
          })
        end

        def decode_redirect(token)
          verifier.verify(token)
        rescue ActiveSupport::MessageVerifier::InvalidSignature
          nil
        end

        def record_click(email_message_id:, organization_id:, target_url:)
          delivery = Delivery.find_by(email_message_id: email_message_id)
          return unless delivery

          delivery.update!(
            clicked_at: delivery.clicked_at || Time.current,
            click_count: delivery.click_count + 1
          )

          EventPublisher.publish(
            event_type: "email.clicked",
            organization_id: organization_id,
            payload: {
              email_id: email_message_id,
              delivery_id: delivery.id,
              target_url: target_url
            }
          )
        rescue ActiveRecord::ActiveRecordError => e
          Rails.logger.error "Click recording failed: #{e.message}"
        end

        def internal_url?(url, base)
          url.start_with?(base)
        end

        def skip_url?(url)
          skip_patterns = %w[
            mailto: tel: sms: facetime: javascript: data:
            unsubscribe list-unsubscribe
          ]
          skip_patterns.any? { |p| url.start_with?(p) || url.include?(p) }
        end

        def verifier
          Rails.application.message_verifier("click_tracking")
        end
      end
    end
  end
end
