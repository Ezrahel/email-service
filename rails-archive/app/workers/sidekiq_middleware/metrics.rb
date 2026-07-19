module SidekiqMiddleware
  class Metrics
    def call(worker, job, queue)
      statsd_key = "sidekiq.#{worker.class.name.underscore.tr('/', '.')}"

      start = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      yield

      duration = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - start) * 1000).round(2)

      record_metric("#{statsd_key}.duration_ms", duration)
      record_metric("#{statsd_key}.success", 1)
    rescue StandardError => e
      duration = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - start) * 1000).round(2)
      record_metric("#{statsd_key}.failed", 1)
      record_metric("#{statsd_key}.duration_ms", duration)
      raise
    end

    private

    def record_metric(key, value)
      # Prometheus metrics via prometheus_exporter
      if defined?(PrometheusExporter::Client)
        PrometheusExporter::Client.default.send_json(
          type: "sidekiq_worker",
          name: key,
          value: value
        )
      end
    rescue StandardError
      # Metrics collection must never break the job
    end
  end
end
