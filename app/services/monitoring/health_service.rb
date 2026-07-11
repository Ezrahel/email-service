module Monitoring
  class HealthService < ApplicationService
    def call
      {
        status: overall_status,
        timestamp: Time.current.iso8601,
        checks: {
          database: check_database,
          redis: check_redis,
          sidekiq: check_sidekiq,
          providers: check_providers,
          storage: check_storage,
          system: check_system
        },
        version: EmailService::VERSION
      }
    rescue StandardError => e
      { status: "error", error: e.message, timestamp: Time.current.iso8601 }
    end

    def liveness
      {
        status: "alive",
        timestamp: Time.current.iso8601,
        uptime: process_uptime
      }
    end

    def readiness
      checks = {
        database: check_database[:healthy],
        redis: check_redis[:healthy],
        sidekiq: check_sidekiq[:healthy]
      }
      overall = checks.values.all?

      {
        status: overall ? "ready" : "not_ready",
        timestamp: Time.current.iso8601,
        checks: checks.transform_keys(&:to_s)
      }
    end

    private

    def overall_status
      checks = [
        check_database[:healthy],
        check_redis[:healthy],
        check_sidekiq[:healthy]
      ]
      checks.all? ? "healthy" : "degraded"
    end

    def check_database
      ActiveRecord::Base.connection.execute("SELECT 1")
      { healthy: true, latency_ms: measure_latency { ActiveRecord::Base.connection.execute("SELECT 1") } }
    rescue StandardError => e
      { healthy: false, error: e.message }
    end

    def check_redis
      start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      Redis.new(url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0")).ping
      latency = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - start) * 1000).round(2)
      { healthy: true, latency_ms: latency }
    rescue StandardError => e
      { healthy: false, error: e.message }
    end

    def check_sidekiq
      stats = Sidekiq::Stats.new
      {
        healthy: stats.processes_size > 0,
        processes: stats.processes_size,
        workers: stats.workers_size,
        enqueued: stats.enqueued,
        retry_count: stats.retry_size
      }
    rescue StandardError => e
      { healthy: false, error: e.message }
    end

    def check_providers
      configs = ProviderConfig.where(is_active: true)
      {
        total: configs.count,
        enabled: configs.count,
        by_provider: configs.group(:provider_type).count
      }
    end

    def check_storage
      {
        active_storage: true
      }
    end

    def check_system
      {
        memory_usage: memory_usage,
        cpu_usage: cpu_usage,
        ruby_version: RUBY_VERSION,
        rails_version: Rails::VERSION::STRING,
        time: Time.current.iso8601
      }
    end

    def memory_usage
      File.read("/proc/self/status").scan(/VmRSS:\s+(\d+)/).flatten.first.to_i
    rescue StandardError
      0
    end

    def cpu_usage
      File.read("/proc/self/stat").split[13].to_f / Process.clock_gettime(Process::CLOCK_MONOTONIC)
    rescue StandardError
      0.0
    end

    def process_uptime
      (Process.clock_gettime(Process::CLOCK_MONOTONIC) / 60).round(2)
    end

    def measure_latency
      start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      yield
      ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - start) * 1000).round(2)
    end
  end
end
