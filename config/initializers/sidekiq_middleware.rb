require "sidekiq"

# ── Server Middleware ──────────────────────────────────────────
Sidekiq.configure_server do |config|
  # Structured logging with request context
  config.server_middleware do |chain|
    chain.add SidekiqMiddleware::Logging
    chain.add SidekiqMiddleware::Metrics
    chain.add SidekiqMiddleware::Tracing
  end

  # Error handlers
  config.error_handlers << proc do |exception, context|
    Rails.logger.error({
      message: "Sidekiq job failed",
      exception: exception.class.name,
      error: exception.message,
      job: context[:job]["class"],
      jid: context[:job]["jid"],
      queue: context[:job]["queue"]
    }.to_json)

    Sentry.capture_exception(exception, extra: context) if defined?(Sentry)
  end

  # Death handler (job exhausted all retries)
  config.death_handlers << ->(job, _ex) do
    Rails.logger.warn({
      message: "Job moved to dead queue",
      job: job["class"],
      jid: job["jid"],
      args: job["args"]
    }.to_json)
  end
end

# ── Client Middleware ──────────────────────────────────────────
Sidekiq.configure_client do |config|
  config.client_middleware do |chain|
    chain.add SidekiqMiddleware::Tracing
  end
end
