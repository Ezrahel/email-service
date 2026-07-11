module Monitoring
  class ProviderHealthDashboard < ApplicationService
    def initialize(organization: nil)
      @organization = organization
    end

    def call
      configs = provider_configs
      provider_names = configs.map(&:provider_type).uniq

      {
        timestamp: Time.current.iso8601,
        summary: build_summary(configs),
        providers: provider_names.map { |name| provider_detail(name) },
        alerts: generate_alerts(provider_names)
      }
    end

    private

    def provider_configs
      scope = ProviderConfig.where(deleted_at: nil)
      scope = scope.where(organization_id: @organization.id) if @organization
      scope
    end

    def build_summary(configs)
      {
        total_providers: configs.select(:provider_type).distinct.count,
        enabled: configs.where(is_active: true).select(:provider_type).distinct.count,
        healthy: 0,
        degraded: 0,
        unhealthy: 0
      }
    end

    def provider_detail(provider_name)
      attempts = ProviderAttempt.where(provider: provider_name)
      recent = attempts.where("created_at > ?", 1.hour.ago)
      last_24h = attempts.where("created_at > ?", 24.hours.ago)

      total_recent = recent.count
      failed_recent = recent.where(status: "failed").count
      total_24h = last_24h.count
      failed_24h = last_24h.where(status: "failed").count

      latency_values = recent.where.not(duration_ms: nil).pluck(:duration_ms)
      avg_latency = latency_values.any? ? (latency_values.sum.to_f / latency_values.size).round(2) : 0

      circuit_state = Providers::Health::CircuitBreaker.new(provider_name).state rescue "closed"

      {
        provider: provider_name,
        status: determine_status(failed_recent, total_recent),
        circuit_breaker: circuit_state,
        recent_1h: {
          attempts: total_recent,
          failures: failed_recent,
          success_rate: rate(total_recent - failed_recent, total_recent),
          avg_latency_ms: avg_latency
        },
        last_24h: {
          attempts: total_24h,
          failures: failed_24h,
          success_rate: rate(total_24h - failed_24h, total_24h)
        },
        configs: provider_configs.where(provider_type: provider_name).map do |config|
          {
            id: config.id,
            organization_id: config.organization_id,
            enabled: config.enabled?,
            region: config.metadata&.dig("region"),
            priority: config.priority
          }
        end
      }
    end

    def determine_status(failures, total)
      return "unknown" if total.zero?

      fail_rate = failures.to_f / total
      if fail_rate > 0.2 then "unhealthy"
      elsif fail_rate > 0.1 then "degraded"
      else "healthy"
      end
    end

    def generate_alerts(provider_names)
      provider_names.each_with_object([]) do |name, alerts|
        detail = provider_detail(name)
        alerts << { provider: name, type: "circuit_open", severity: "critical", message: "Circuit breaker open for #{name}" } if detail[:circuit_breaker] == "open"
        alerts << { provider: name, type: "high_failure", severity: "warning", message: "High failure rate for #{name}: #{(1 - detail.dig(:recent_1h, :success_rate).to_f / 100) * 100}%" } if detail.dig(:recent_1h, :success_rate).to_f < 80
      end
    end

    def rate(part, total)
      return 0.0 if total.zero?
      (part.to_f / total * 100).round(2)
    end
  end
end
