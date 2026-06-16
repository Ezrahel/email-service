if ENV.fetch("OTEL_EXPORTER", "none") != "none"
  require "opentelemetry-sdk"
  require "opentelemetry-exporter-otlp"
  require "opentelemetry-instrumentation-all"

  OpenTelemetry::SDK.configure do |c|
    c.service_name = ENV.fetch("OTEL_SERVICE_NAME", "email-service")
    c.service_version = EmailService::Application::VERSION rescue "0.1.0"

    c.use_all(
      "OpenTelemetry::Instrumentation::Rack" => { },
      "OpenTelemetry::Instrumentation::ActiveRecord" => {
        db_statement: :obfuscate
      },
      "OpenTelemetry::Instrumentation::Sidekiq" => { },
      "OpenTelemetry::Instrumentation::Redis" => { },
      "OpenTelemetry::Instrumentation::Net::HTTP" => { },
      "OpenTelemetry::Instrumentation::ConcurrentRuby" => { },
      "OpenTelemetry::Instrumentation::RSpec" => { } if Rails.env.test?
    )
  end
end
