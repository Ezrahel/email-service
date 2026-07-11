class HealthController < ActionController::API
  # No authentication for health checks

  VERSION = "0.2.0".freeze

  def show
    render json: Monitoring::HealthService.call
  end

  def liveness
    render json: Monitoring::HealthService.new.liveness
  end

  def readiness
    render json: Monitoring::HealthService.new.readiness
  end
end
