module Api
  module V1
    class DashboardController < BaseController
      before_action :require_dashboard_scope!

      def overview
        render_success Dashboard::Overview.call(
          organization: current_organization,
          since: parse_time(:since, 30.days.ago),
          until_time: parse_time(:until, Time.current)
        )
      end

      def deliverability
        render_success Dashboard::Deliverability.call(
          organization: current_organization,
          since: parse_time(:since, 30.days.ago),
          until_time: parse_time(:until, Time.current),
          granularity: params[:granularity] || "daily"
        )
      end

      def usage
        render_success Dashboard::Usage.call(
          organization: current_organization,
          since: parse_time(:since, 30.days.ago),
          until_time: parse_time(:until, Time.current),
          granularity: params[:granularity] || "daily"
        )
      end

      def providers
        render_success Dashboard::ProviderPerformance.call(
          organization: current_organization,
          since: parse_time(:since, 30.days.ago),
          until_time: parse_time(:until, Time.current)
        )
      end

      def activity
        render_success Dashboard::Activity.call(
          organization: current_organization,
          since: parse_time(:since, 7.days.ago),
          until_time: parse_time(:until, Time.current),
          cursor: params[:cursor],
          per_page: params.fetch(:per_page, 50).to_i
        )
      end

      def alerts
        render_success Dashboard::Alerts.call(
          organization: current_organization,
          since: parse_time(:since, 24.hours.ago),
          until_time: parse_time(:until, Time.current)
        )
      end

      private

      def parse_time(name, default)
        return default unless params[name].present?
        Time.parse(params[name])
      rescue ArgumentError, TypeError
        default
      end

      def require_dashboard_scope!
        require_scope!("analytics:read")
      end
    end
  end
end
