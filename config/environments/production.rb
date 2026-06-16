require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false

  config.force_ssl = true

  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", :info).to_sym
  config.log_tags = [:request_id]
  config.log_formatter = ::Logger::Formatter.new

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger = ActiveSupport::Logger.new($stdout)
    logger.formatter = config.log_formatter
    config.logger = ActiveSupport::TaggedLogging.new(logger)
  end

  config.cache_store = :redis_cache_store, {
    url: ENV.fetch("REDIS_CACHE_URL", "redis://localhost:6379/2"),
    pool_size: ENV.fetch("RAILS_MAX_THREADS", 10).to_i + 5,
    expires_in: 1.hour,
    race_condition_ttl: 10
  }

  config.active_support.report_deprecations = false
  config.active_record.dump_schema_after_migration = false

  config.action_mailer.default_url_options = {
    host: ENV.fetch("HOST", "localhost"),
    protocol: "https"
  }
  config.action_mailer.asset_host = ENV.fetch("HOST", "https://localhost")
  config.action_mailer.perform_caching = false

  config.active_record.query_log_tags_enabled = true
  config.active_record.query_log_tags = [:application, :controller, :action, :job]
end
