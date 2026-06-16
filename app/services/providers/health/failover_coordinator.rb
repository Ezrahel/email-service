module Providers
  module Health
    class FailoverCoordinator
      FailoverPlan = Struct.new(:primary, :failovers, :current_index, keyword_init: true) do
        def current
          failovers[current_index] || primary
        end

        def next!
          self.current_index += 1
          current
        end

        def exhausted?
          current_index >= failovers.length
        end
      end

      def initialize(organization:, email: nil, mode: "priority")
        @organization = organization
        @email = email
        @mode = mode
      end

      def plan
        configs = available_configs
        return nil if configs.empty?

        primary = configs.first
        failovers = configs[1..] || []

        FailoverPlan.new(
          primary: primary,
          failovers: failovers,
          current_index: 0
        )
      end

      def execute
        failover_plan = plan
        return yield_result(nil, "No providers available") unless failover_plan

        loop do
          config = failover_plan.current
          cb = CircuitBreaker.new(config)

          unless cb.allow_request?
            if failover_plan.exhausted?
              return yield_result(config, "Circuit open, no more failovers")
            end
            failover_plan.next!
            next
          end

          result = yield(config)
          return result if result.success?

          cb.record_failure

          if failover_plan.exhausted?
            return yield_result(config, "All providers exhausted")
          end

          config.update_health!(success: false)
          failover_plan.next!
        end
      end

      private

      def available_configs
        Router.new(
          organization: @organization,
          email: @email,
          mode: @mode
        ).tap { |r| r.select }
        @organization.provider_configs.active.healthy.by_priority.to_a
      end

      def yield_result(config, error)
        OpenStruct.new(
          success?: false,
          provider_config: config,
          provider_type: config&.provider_type,
          error: error,
          value: nil
        )
      end
    end
  end
end
