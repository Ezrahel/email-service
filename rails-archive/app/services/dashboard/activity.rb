module Dashboard
  class Activity < ApplicationService
    def initialize(organization:, since:, until_time:, cursor: nil, per_page: 50)
      @organization = organization
      @since = since
      @until = until_time
      @cursor = cursor
      @per_page = per_page
    end

    def call
      events = load_events
      has_more = events.size > @per_page
      events = events.first(@per_page) if has_more

      next_cursor = events.last&.event_timestamp&.iso8601 if has_more

      {
        events: events.map { |e| serialize_event(e) },
        pagination: {
          has_more: has_more,
          cursor: next_cursor,
          per_page: @per_page
        }
      }
    end

    private

    def load_events
      scope = @organization.delivery_events
        .where(event_timestamp: @since..@until)
        .order(event_timestamp: :desc)
        .limit(@per_page + 1)

      if @cursor.present?
        cursor_time = Time.parse(@cursor)
        scope = scope.where("event_timestamp < ?", cursor_time)
      end

      scope.to_a
    rescue ArgumentError, TypeError
      scope.to_a
    end

    def serialize_event(event)
      {
        id: event.id,
        type: event.event_type,
        provider: event.provider,
        timestamp: event.event_timestamp,
        email_id: event.email_message_id,
        details: event.metadata || {}
      }
    end
  end
end
