class EventConsumer
  GROUP_NAME = "email_service_workers"
  CONSUMER_NAME = "worker_#{Socket.gethostname}_#{Process.pid}"
  STREAM_KEY = "events:delivery"

  class << self
    def start!
      Thread.new { consume_loop }
    end

    def consume_loop
      loop do
        process_events
      rescue Redis::CommandError, Redis::CannotConnectError => e
        Rails.logger.error "Event consumer error: #{e.message}"
        sleep 1
      rescue StandardError => e
        Rails.logger.error "Event consumer unexpected error: #{e.message}"
        sleep 5
      end
    end

    def process_events
      ensure_group!

      results = REDIS_STREAMS.xreadgroup(
        GROUP_NAME, CONSUMER_NAME,
        STREAM_KEY, ">",
        count: 10,
        block: 2000
      )

      return unless results

      stream_entries = results[STREAM_KEY.to_s] || results[STREAM_KEY.to_sym]
      return unless stream_entries

      stream_entries.each do |entry|
        event_id, data = entry
        process_event(data)
        REDIS_STREAMS.xack(STREAM_KEY, GROUP_NAME, event_id)
      end
    end

    private

    def ensure_group!
      REDIS_STREAMS.xgroup(:create, STREAM_KEY, GROUP_NAME, "$", mkstream: true)
    rescue Redis::CommandError => e
      raise unless e.message.include?("BUSYGROUP")
    end

    def process_event(data)
      event_type = data["event_type"]
      organization_id = data["organization_id"]
      payload = JSON.parse(data["payload"] || "{}")

      case event_type
      when "email.delivered"  then handle_delivered(payload)
      when "email.failed"     then handle_failed(payload)
      when "email.bounced"    then handle_bounced(payload)
      when "email.opened"     then handle_opened(payload)
      when "email.clicked"    then handle_clicked(payload)
      end
    rescue JSON::ParserError => e
      Rails.logger.error "Event parse error: #{e.message}"
    end

    def handle_delivered(payload)
      email = EmailMessage.find_by(id: payload["email_id"])
      email&.mark_delivered!
    end

    def handle_failed(payload)
      email = EmailMessage.find_by(id: payload["email_id"])
      email&.mark_failed!(reason: payload["error"] || "Unknown")
    end

    def handle_bounced(payload)
      email = EmailMessage.find_by(id: payload["email_id"])
      email&.mark_bounced!(reason: payload["error"] || "Bounced")
    end

    def handle_opened(payload)
      delivery = Delivery.find_by(id: payload["delivery_id"])
      return unless delivery

      delivery.update!(
        opened_at: Time.current,
        open_count: delivery.open_count + 1
      )
    end

    def handle_clicked(payload)
      delivery = Delivery.find_by(id: payload["delivery_id"])
      return unless delivery

      delivery.update!(
        clicked_at: Time.current,
        click_count: delivery.click_count + 1
      )
    end
  end
end
