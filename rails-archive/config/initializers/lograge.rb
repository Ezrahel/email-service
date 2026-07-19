Rails.application.configure do
  config.lograge.enabled = true
  config.lograge.formatter = Lograge::Formatters::Logstash.new

  config.lograge.custom_options = lambda do |event|
    {
      request_id: event.payload[:request_id],
      user_id: event.payload[:user_id],
      organization_id: event.payload[:organization_id],
      api_key_id: event.payload[:api_key_id],
      params: event.payload[:params].to_s,
      exception: event.payload[:exception]&.first,
      exception_message: event.payload[:exception]&.last,
      duration: event.duration
    }
  end

  config.lograge.ignore_actions = ["HealthController#show"]
  config.lograge.base_controller_class = ["ActionController::API"]
end
