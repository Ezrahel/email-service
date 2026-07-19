class CircuitChecker
  FAILURE_THRESHOLD = 5
  RESET_TIMEOUT = 60.seconds
  HALF_OPEN_MAX = 3

  class << self
    def open?(provider_type, organization_id)
      key = circuit_key(provider_type, organization_id)
      failures = redis.get(key).to_i

      return false if failures < FAILURE_THRESHOLD

      # Check if reset timeout has elapsed
      last_failure = redis.get("#{key}:last_failure")
      if last_failure && (Time.current.to_f - last_failure.to_f) > RESET_TIMEOUT.to_f
        # Half-open: allow a few test requests
        half_open_count = redis.incr("#{key}:half_open")
        redis.expire("#{key}:half_open", RESET_TIMEOUT.to_i)

        if half_open_count <= HALF_OPEN_MAX
          return false # Allow the request through
        end
      end

      true
    end

    def record_failure(provider_type, organization_id)
      key = circuit_key(provider_type, organization_id)
      redis.multi do |pipe|
        pipe.incr(key)
        pipe.expire(key, RESET_TIMEOUT.to_i)
        pipe.set("#{key}:last_failure", Time.current.to_f)
        pipe.expire("#{key}:last_failure", RESET_TIMEOUT.to_i)
      end
    end

    def record_success(provider_type, organization_id)
      key = circuit_key(provider_type, organization_id)
      redis.del(key, "#{key}:last_failure", "#{key}:half_open")
    end

    def reset!(provider_type, organization_id)
      key = circuit_key(provider_type, organization_id)
      redis.del(key, "#{key}:last_failure", "#{key}:half_open")
    end

    private

    def circuit_key(provider_type, organization_id)
      "circuit:#{provider_type}:#{organization_id}"
    end

    def redis
      REDIS_POOL.with { |conn| conn }
    end
  end
end
