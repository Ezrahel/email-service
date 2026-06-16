require "sidekiq"
require "sidekiq-unique-jobs"
require "sidekiq/throttled"
require "sidekiq-status"

Sidekiq::Throttled.setup!

Sidekiq.configure_server do |config|
  config.redis = {
    url: ENV.fetch("REDIS_SIDEKIQ_URL", "redis://localhost:6379/1"),
    pool_size: ENV.fetch("SIDEKIQ_CONCURRENCY", 10).to_i + 5
  }

  config.client_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Client
  end

  config.server_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Server
    chain.add Sidekiq::Throttled::Middleware
  end

  SidekiqUniqueJobs::Server.configure(config)

  config.death_handlers << lambda do |job, ex|
    Rails.logger.warn "[Sidekiq] #{job['class']} died: #{ex.message}"
  end

  config.error_handlers << proc do |ex, context|
    Rails.logger.error "[Sidekiq] Error in #{context[:job]["class"]}: #{ex.message}"
  end

  config.server_middleware do |chain|
    chain.add Sidekiq::Status::ServerMiddleware, expiration: 86_400
  end
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: ENV.fetch("REDIS_SIDEKIQ_URL", "redis://localhost:6379/1"),
    pool_size: 5
  }

  config.client_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Client
    chain.add Sidekiq::Status::ClientMiddleware
  end
end
