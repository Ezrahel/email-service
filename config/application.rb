require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_record/railtie"
require "active_job/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)

module EmailService
  class Application < Rails::Application
    config.load_defaults 8.0

    config.api_only = true

    config.autoload_lib(ignore: %w[assets tasks])

    config.active_job.queue_adapter = :sidekiq

    config.action_mailer.delivery_method = :letter_opener if Rails.env.development?
    config.action_mailer.asset_host = ENV.fetch("HOST", "http://localhost:3000")

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot, dir: "spec/factories"
      g.helper false
      g.javascripts false
      g.stylesheets false
      g.channel assets: false
    end
  end
end
