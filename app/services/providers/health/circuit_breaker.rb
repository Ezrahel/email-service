module Providers
  module Health
    class CircuitBreaker
      State = Struct.new(:status, :failure_count, :last_failure_at, :half_open_attempts, keyword_init: true) do
        def healthy?
          status == "healthy"
        end

        def open?
          status == "open"
        end

        def half_open?
          status == "half_open"
        end

        def degraded?
          status == "degraded"
        end
      end

      FAILURE_THRESHOLD = 5
      RESET_TIMEOUT = 60.seconds
      HALF_OPEN_MAX = 3
      DEGRADED_THRESHOLD = 3

      def initialize(provider_config)
        @provider_config = provider_config
        @provider_type = provider_config.provider_type
        @organization_id = provider_config.organization_id
      end

      def allow_request?
        state = current_state
        return true if state.healthy? || state.degraded?
        return false if state.open?
        try_half_open(state)
      end

      def record_success
        REDIS_POOL.with do |conn|
          key = circuit_key
          conn.del(
            "#{key}:failures",
            "#{key}:last_failure",
            "#{key}:half_open",
            "#{key}:status"
          )
        end
      end

      def record_failure
        REDIS_POOL.with do |conn|
          key = circuit_key
          failures = conn.incr("#{key}:failures")
          conn.expire("#{key}:failures", RESET_TIMEOUT.to_i)
          conn.set("#{key}:last_failure", Time.current.to_f)
          conn.expire("#{key}:last_failure", RESET_TIMEOUT.to_i)

          if failures >= FAILURE_THRESHOLD
            conn.set("#{key}:status", "open")
            conn.expire("#{key}:status", RESET_TIMEOUT.to_i)
          elsif failures >= DEGRADED_THRESHOLD
            conn.set("#{key}:status", "degraded")
            conn.expire("#{key}:status", RESET_TIMEOUT.to_i)
          end
        end
      end

      def current_state
        REDIS_POOL.with do |conn|
          key = circuit_key
          status = conn.get("#{key}:status") || "healthy"
          failures = conn.get("#{key}:failures").to_i
          last_failure = conn.get("#{key}:last_failure")
          half_open = conn.get("#{key}:half_open").to_i

          if status == "open" && last_failure
            elapsed = Time.current.to_f - last_failure.to_f
            if elapsed >= RESET_TIMEOUT.to_f
              status = "half_open"
              conn.set("#{key}:status", "half_open")
            end
          end

          State.new(
            status: status,
            failure_count: failures,
            last_failure_at: last_failure ? Time.at(last_failure.to_f) : nil,
            half_open_attempts: half_open
          )
        end
      end

      def reset!
        REDIS_POOL.with do |conn|
          key = circuit_key
          conn.del("#{key}:failures", "#{key}:last_failure", "#{key}:half_open", "#{key}:status")
        end
      end

      private

      def circuit_key
        "cb:#{@provider_type}:#{@organization_id}"
      end

      def try_half_open(state)
        REDIS_POOL.with do |conn|
          key = circuit_key
          attempts = conn.incr("#{key}:half_open")
          conn.expire("#{key}:half_open", RESET_TIMEOUT.to_i)

          if attempts <= HALF_OPEN_MAX
            true
          else
            conn.set("#{key}:status", "open")
            false
          end
        end
      end
    end
  end
end
