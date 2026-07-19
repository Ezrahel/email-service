module Providers
  module Routing
    class Router
      Selection = Struct.new(:provider_config, :provider_type, :reason, keyword_init: true)

      ROUTING_MODES = %w[priority weighted least_latency cost_optimized failover_only].freeze

      def initialize(organization:, email: nil, domain: nil, mode: nil)
        @organization = organization
        @email = email
        @domain = domain
        @mode = resolve_mode(mode)
      end

      def select
        configs = available_configs
        return nil if configs.empty?

        case @mode
        when "priority"       then select_priority(configs)
        when "weighted"       then select_weighted(configs)
        when "least_latency"  then select_least_latency(configs)
        when "cost_optimized" then select_cost_optimized(configs)
        when "failover_only"  then select_priority(configs)
        else                       select_priority(configs)
        end
      end

      def select_failover(failed_provider_type)
        configs = available_configs.reject { |c| c.provider_type == failed_provider_type }
        return nil if configs.empty?

        Selection.new(
          provider_config: configs.first,
          provider_type: configs.first.provider_type,
          reason: "failover"
        )
      end

      private

      def resolve_mode(mode)
        return mode if mode && ROUTING_MODES.include?(mode)

        org_override = @organization.settings&.dig("routing_mode")
        return org_override if org_override && ROUTING_MODES.include?(org_override)

        if @domain&.settings&.dig("routing_mode")
          domain_override = @domain.settings["routing_mode"]
          return domain_override if ROUTING_MODES.include?(domain_override)
        end

        "priority"
      end

      def available_configs
        configs = @organization.provider_configs.active.includes(:provider_config)

        if @domain&.provider_override.present?
          configs = configs.where(provider_type: @domain.provider_override)
        end

        configs.healthy.by_priority.to_a
      end

      def select_priority(configs)
        return nil if configs.empty?

        top_priority = configs.first.priority
        candidates = configs.select { |c| c.priority == top_priority }
        pick = candidates.sample

        Selection.new(
          provider_config: pick,
          provider_type: pick.provider_type,
          reason: "priority_#{pick.priority}"
        )
      end

      def select_weighted(configs)
        return nil if configs.empty?

        candidates = configs.select { |c| c.weight > 0 }
        return select_priority(configs) if candidates.empty?

        total = candidates.sum(&:weight)
        roll = rand(1..total)
        cumulative = 0

        candidates.each do |c|
          cumulative += c.weight
          if roll <= cumulative
            return Selection.new(
              provider_config: c,
              provider_type: c.provider_type,
              reason: "weighted_#{c.weight}of#{total}"
            )
          end
        end

        fallback = candidates.first
        Selection.new(
          provider_config: fallback,
          provider_type: fallback.provider_type,
          reason: "weighted_fallback"
        )
      end

      def select_least_latency(configs)
        candidates = configs.sort_by { |c| c.last_health_check_at&.to_f || 0 }

        pick = candidates.min_by do |c|
          latency = c.settings&.dig("last_latency_ms").to_f
          latency.positive? ? latency : Float::INFINITY
        end

        pick ||= candidates.first
        return nil unless pick

        Selection.new(
          provider_config: pick,
          provider_type: pick.provider_type,
          reason: "least_latency"
        )
      end

      def select_cost_optimized(configs)
        cost_map = {
          "ses" => 0.0001,
          "sendgrid" => 0.001,
          "mailgun" => 0.0008,
          "postmark" => 0.001,
          "smtp" => 0.0
        }

        candidates = configs.sort_by { |c| cost_map[c.provider_type] || Float::INFINITY }
        pick = candidates.first
        return nil unless pick

        Selection.new(
          provider_config: pick,
          provider_type: pick.provider_type,
          reason: "cost_optimized"
        )
      end
    end
  end
end
