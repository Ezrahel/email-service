class HealthController < ActionController::API
  # No authentication for health checks

  def show
    render json: {
      status: "ok",
      timestamp: Time.current.iso8601,
      version: self.class::VERSION
    }
  end

  def liveness
    render json: { status: "alive" }
  end

  def readiness
    checks = {
      database: database_healthy?,
      redis: redis_healthy?,
      sidekiq: sidekiq_healthy?
    }

    overall = checks.values.all?

    status_code = overall ? :ok : :service_unavailable
    render json: { status: overall ? "ready" : "not_ready", checks: checks }, status: status_code
  end

  private

  VERSION = "0.1.0".freeze

  def database_healthy?
    ActiveRecord::Base.connection.execute("SELECT 1")
    true
  rescue StandardError
    false
  end

  def redis_healthy?
    Redis.new(url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0")).ping == "PONG"
  rescue StandardError
    false
  end

  def sidekiq_healthy?
    stats = Sidekiq::Stats.new
    stats.processes_size > 0
  rescue StandardError
    false
  end
end
