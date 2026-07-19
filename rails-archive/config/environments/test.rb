require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = ENV["CI"].present?
  config.consider_all_requests_local = true

  config.cache_store = :memory_store, { size: 64.megabytes }

  config.public_file_server.headers = { "Cache-Control" => "public, max-age=#{1.hour.to_i}" }

  config.active_support.deprecation = :stderr
  config.active_support.disallowed_deprecation = :raise
  config.active_support.disallowed_deprecation_warnings = []

  config.action_controller.allow_forgery_protection = false
  config.action_mailer.perform_caching = false
  config.action_mailer.delivery_method = :test

  config.active_record.query_log_tags_enabled = false
  config.log_level = :warn

  config.after_initialize do
    Shoulda::Matchers.configure do |shoulda|
      shoulda.integrate do |with|
        with.test_framework :rspec
        with.library :rails
      end
    end
  end
end
