module Dashboard
  class ProviderPerformance < ApplicationService
    def initialize(organization:, since:, until_time:)
      @organization = organization
      @since = since
      @until = until_time
    end

    def call
      providers = compute_provider_stats
      {
        period: { since: @since, until: @until },
        providers: providers,
        totals: compute_totals(providers),
        health: compute_provider_health
      }
    end

    private

    def compute_provider_stats
      @organization.email_messages
        .joins(delivery: :provider_attempts)
        .where(provider_attempts: { created_at: @since..@until })
        .group("provider_attempts.provider")
        .select(
          "provider_attempts.provider",
          "COUNT(*) AS total",
          "COUNT(*) FILTER (WHERE provider_attempts.status = 'success') AS success",
          "COUNT(*) FILTER (WHERE provider_attempts.status = 'failed') AS failed",
          "COUNT(DISTINCT provider_attempts.delivery_id) AS unique_deliveries",
          "AVG(provider_attempts.duration_ms)::numeric(10,2) AS avg_duration_ms",
          "MIN(provider_attempts.duration_ms)::numeric(10,2) AS min_duration_ms",
          "MAX(provider_attempts.duration_ms)::numeric(10,2) AS max_duration_ms"
        )
        .order("total DESC")
        .map do |r|
          rate = r.total.to_i > 0 ? (r.success.to_f / r.total * 100).round(2) : 0.0
          {
            provider: r.provider,
            total_attempts: r.total.to_i,
            success_count: r.success.to_i,
            failed_count: r.failed.to_i,
            unique_deliveries: r.unique_deliveries.to_i,
            success_rate: rate,
            avg_duration_ms: r.avg_duration_ms,
            min_duration_ms: r.min_duration_ms,
            max_duration_ms: r.max_duration_ms
          }
        end
    end

    def compute_totals(providers)
      total_attempts = providers.sum { |p| p[:total_attempts] }
      total_success = providers.sum { |p| p[:success_count] }

      {
        total_attempts: total_attempts,
        total_success: total_success,
        total_failed: providers.sum { |p| p[:failed_count] },
        overall_success_rate: total_attempts > 0 ? (total_success.to_f / total_attempts * 100).round(2) : 0.0,
        provider_count: providers.size
      }
    end

    def compute_provider_health
      ProviderConfig
        .where(organization_id: @organization.id)
        .map do |config|
          recent = ProviderAttempt
            .where(provider: config.provider)
            .where("created_at > ?", 1.hour.ago)

          total = recent.count
          failed = recent.where(status: "failed").count

          {
            provider: config.provider,
            enabled: config.enabled?,
            recent_attempts: total,
            recent_failures: failed,
            health_score: total > 0 ? ((total - failed).to_f / total * 100).round(2) : 100.0,
            last_attempt_at: recent.maximum(:created_at)
          }
        end
    end
  end
end
