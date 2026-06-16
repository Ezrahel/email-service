Rails.application.config.generators do |g|
  g.orm :active_record, primary_key_type: :uuid
  g.api_only = true
  g.resource_route false
  g.test_framework :rspec,
    fixtures: true,
    fixture_replacement: :factory_bot,
    view_specs: false,
    helper_specs: false,
    routing_specs: false,
    controller_specs: true,
    request_specs: true
  g.factory_bot dir: "spec/factories"
end
