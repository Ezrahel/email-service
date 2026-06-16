if Rails.env.production? || ENV["PROMETHEUS_EXPORTER_ENABLED"]
  require "prometheus_exporter/middleware"
  require "prometheus_exporter/instrumentation"

  # Middleware for HTTP metrics
  Rails.application.middleware.unshift PrometheusExporter::Middleware

  # Collect sidekiq metrics
  PrometheusExporter::Instrumentation::Sidekiq.register if defined?(Sidekiq)

  # Collect process metrics
  PrometheusExporter::Instrumentation::Process.start(type: "master")

  # Periodically collect ActiveRecord stats
  PrometheusExporter::Instrumentation::ActiveRecord.start(
    custom_labels: { type: "email_service" },
    config_labels: [:host, :database]
  )
end
