module Api
  module V1
    class AnalyticsController < BaseController
      before_action :require_analytics_scope!

      def overview
        stats = Analytics::Overview.call(
          organization: current_organization,
          since: parse_time_param(:since, 30.days.ago),
          until: parse_time_param(:until, Time.current)
        )

        render_success stats
      end

      def deliverability
        stats = Analytics::Deliverability.call(
          organization: current_organization,
          granularity: params[:granularity] || "daily",
          since: parse_time_param(:since, 30.days.ago),
          until: parse_time_param(:until, Time.current)
        )

        render_success stats
      end

      def events
        events = current_organization.delivery_events
          .by_type(params[:event_type])
          .since(parse_time_param(:since, 7.days.ago))
          .order(event_timestamp: :desc)

        records, pagy = paginate(events)
        render_collection(records, AnalyticsEventSerializer, meta: pagy_meta(pagy))
      end

      private

      def parse_time_param(name, default)
        return default unless params[name].present?

        Time.parse(params[name])
      rescue ArgumentError, TypeError
        default
      end

      def require_analytics_scope!
        require_scope!("analytics:read")
      end

      def pagy_meta(pagy)
        { page: pagy.page, per_page: pagy.items, total: pagy.count, pages: pagy.pages }
      end
    end
  end
end
