module Analytics
  class MetricsCollector < ApplicationService
    def call
      {
        queued: collect_queue_metrics,
        processed: collect_processing_metrics,
        rates: collect_rate_metrics,
        latency: collect_latency_metrics,
        timestamp: Time.current
      }
    end

    private

    def collect_queue_metrics
      sidekiq_stats = Sidekiq::Stats.new

      {
        enqueued: sidekiq_stats.enqueued,
        queued: sidekiq_stats.queues.sum { |_, v| v || 0 },
        retry_count: sidekiq_stats.retry_size,
        dead_count: sidekiq_stats.dead_size,
        scheduled: sidekiq_stats.scheduled_size,
        processes: sidekiq_stats.processes_size,
        workers: sidekiq_stats.workers_size
      }
    rescue StandardError => e
      { error: e.message, enqueued: 0, queued: 0, retry_count: 0 }
    end

    def collect_processing_metrics
      {}.tap do |h|
        %w[default email_analytics webhooks providers maintenance].each do |queue|
          h[queue] = Sidekiq::Queue.new(queue).size
        end
      end
    rescue StandardError
      {}
    end

    def collect_rate_metrics
      recent = EmailMessage.where("created_at > ?", 5.minutes.ago)

      {
        messages_per_minute: recent.count / 5,
        delivery_rate: calculate_rate(
          recent.where(status: %w[delivered sent]).count,
          recent.count
        ),
        error_rate: calculate_rate(
          recent.where(status: "failed").count,
          recent.count
        ),
        bounce_rate: calculate_rate(
          recent.where(status: "bounced").count,
          recent.count
        )
      }
    end

    def collect_latency_metrics
      recent = Delivery
        .where("last_attempt_at > ?", 5.minutes.ago)
        .where.not(last_attempt_duration_ms: nil)
        .pluck(:last_attempt_duration_ms)

      if recent.any?
        sorted = recent.sort
        {
          avg_ms: (recent.sum.to_f / recent.size).round(2),
          p50_ms: sorted[sorted.length * 0.50],
          p90_ms: sorted[sorted.length * 0.90],
          p99_ms: sorted[sorted.length * 0.99],
          sample_size: recent.size
        }
      else
        { avg_ms: 0, p50_ms: 0, p90_ms: 0, p99_ms: 0, sample_size: 0 }
      end
    end

    def calculate_rate(part, total)
      return 0.0 if total.zero?
      (part.to_f / total * 100).round(2)
    end
  end
end
