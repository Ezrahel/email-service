module Providers
  module Health
    class HealthMonitor
      CheckResult = Struct.new(:healthy?, :health_score, :latency_ms, :error, :checked_at, keyword_init: true)

      HEALTHY_THRESHOLD = 70
      DEGRADED_THRESHOLD = 40
      CHECK_INTERVAL = 60.seconds

      class << self
        def check(provider_config)
          return cached_result(provider_config) if recent_check?(provider_config)

          result = perform_check(provider_config)
          cache_result(provider_config, result)
          provider_config.update_health!(success: result.healthy?)
          result
        end

        def force_check(provider_config)
          result = perform_check(provider_config)
          provider_config.update_health!(success: result.healthy?)
          cache_result(provider_config, result)
          result
        end

        def status_label(health_score)
          case health_score
          when HEALTHY_THRESHOLD.. then "healthy"
          when DEGRADED_THRESHOLD...HEALTHY_THRESHOLD then "degraded"
          when 1...DEGRADED_THRESHOLD then "failed"
          else "unknown"
          end
        end

        private

        def perform_check(provider_config)
          start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
          adapter = provider_config.adapter

          begin
            result = adapter.health_check
            latency = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - start) * 1000).round(2)

            if result[:healthy]
              CheckResult.new(
                healthy?: true,
                health_score: compute_score(provider_config, latency),
                latency_ms: latency,
                checked_at: Time.current
              )
            else
              CheckResult.new(
                healthy?: false,
                health_score: [provider_config.health_score - 10, 0].max,
                latency_ms: latency,
                error: result[:error],
                checked_at: Time.current
              )
            end
          rescue StandardError => e
            latency = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - start) * 1000).round(2)
            CheckResult.new(
              healthy?: false,
              health_score: [provider_config.health_score - 20, 0].max,
              latency_ms: latency,
              error: e.message,
              checked_at: Time.current
            )
          end
        end

        def compute_score(provider_config, latency)
          base = provider_config.health_score
          latency_penalty = [latency / 100, 30].min
          [base - latency_penalty + 5, 100].min
        end

        def recent_check?(provider_config)
          return false unless provider_config.last_health_check_at
          provider_config.last_health_check_at > CHECK_INTERVAL.ago
        end

        def cached_result(provider_config)
          score = provider_config.health_score
          CheckResult.new(
            healthy?: score >= HEALTHY_THRESHOLD,
            health_score: score,
            checked_at: provider_config.last_health_check_at
          )
        end

        def cache_result(provider_config, result)
          REDIS_POOL.with do |conn|
            key = "health:#{provider_config.provider_type}:#{provider_config.organization_id}"
            conn.multi do |pipe|
              pipe.setex("#{key}:score", CHECK_INTERVAL.to_i, result.health_score)
              pipe.setex("#{key}:latency", CHECK_INTERVAL.to_i, result.latency_ms)
            end
          end
        end
      end
    end
  end
end
