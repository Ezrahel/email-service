module ApiHelpers
  def json_body
    JSON.parse(response.body)
  rescue JSON::ParserError
    {}
  end

  def json_data
    json_body["data"]
  end

  def json_errors
    json_body["error"]
  end

  def json_meta
    json_body["meta"]
  end

  def auth_header(api_key = nil)
    key = api_key || create(:api_key).full_key
    { "Authorization" => "Bearer #{key}", "Content-Type" => "application/json" }
  end

  def json_headers
    { "Content-Type" => "application/json", "Accept" => "application/json" }
  end
end

RSpec.configure do |config|
  config.include ApiHelpers, type: :request
end
