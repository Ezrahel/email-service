module Providers
  module Tracking
    class EventCollector
      class << self
        def record_open(token, request)
          email_message = TrackingPixelGenerator.verify_token(token)
          return { success: false, error: "Invalid token" } unless email_message

          delivery = email_message.delivery
          return { success: false, error: "No delivery found" } unless delivery

          delivery.update!(
            opened_at: delivery.opened_at || Time.current,
            open_count: delivery.open_count + 1
          )

          EventPublisher.publish(
            event_type: "email.opened",
            organization_id: email_message.organization_id,
            payload: {
              email_id: email_message.id,
              delivery_id: delivery.id,
              user_agent: request.user_agent,
              ip_address: request.remote_ip
            }
          )

          { success: true }
        rescue ActiveRecord::ActiveRecordError => e
          { success: false, error: e.message }
        end

        def record_click(redirect_token)
          target_url = LinkRedirector.resolve_redirect(redirect_token)
          return { success: false, error: "Invalid redirect token" } unless target_url

          { success: true, target_url: target_url }
        end
      end
    end
  end
end
