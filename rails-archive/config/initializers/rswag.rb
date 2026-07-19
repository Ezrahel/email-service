Rswag::Api.configure do |c|
  c.swagger_root = Rails.root.join("lib/openapi/v1").to_s
  c.swagger_filter = lambda { |swagger, env| swagger }
end

Rswag::Ui.configure do |c|
  c.swagger_endpoint "/api-docs/v1/openapi.yaml", "Email Service API v1"
end
