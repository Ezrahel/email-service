class WebhookDispatcher
  Result = Struct.new(:success?, :http_status, :duration_ms, :response_body, :error, keyword_init: true)

  def initialize(delivery:)
    @webhook_delivery = delivery
    @webhook = delivery.webhook
  end

  def deliver!
    start = Process.clock_gettime(Process::CLOCK_MONOTONIC)

    payload = build_payload
    signature = WebhookSigner.sign(payload, @webhook.secret)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"
    http.open_timeout = 5
    http.read_timeout = @webhook.timeout_ms / 1000

    request = Net::HTTP::Post.new(uri.path)
    request["Content-Type"] = "application/json"
    request["User-Agent"] = "EmailService-Webhook/1.0"
    request["X-EmailService-Signature"] = signature
    request["X-EmailService-Event"] = @webhook_delivery.event_type
    request["X-EmailService-Delivery-Id"] = @webhook_delivery.id

    @webhook.headers.each { |k, v| request[k] = v } if @webhook.headers.is_a?(Hash)

    request.body = payload.to_json

    response = http.request(request)
    duration = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - start) * 1000).round(2)

    if response.is_a?(Net::HTTPSuccess)
      Result.new(
        success?: true,
        http_status: response.code.to_i,
        duration_ms: duration,
        response_body: response.body
      )
    else
      Result.new(
        success?: false,
        http_status: response.code.to_i,
        duration_ms: duration,
        error: "HTTP #{response.code}: #{response.message}"
      )
    end
  rescue Net::TimeoutError => e
    duration = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - start) * 1000).round(2)
    Result.new(success?: false, duration_ms: duration, error: "Timeout: #{e.message}")
  rescue StandardError => e
    duration = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - start) * 1000).round(2)
    Result.new(success?: false, duration_ms: duration, error: e.message)
  end

  def self.dispatch_async(event_type:, organization_id:, payload:)
    webhooks = Webhook.active.for_event(event_type)
      .where(organization_id: organization_id)

    webhooks.each do |webhook|
      delivery = webhook.webhook_deliveries.create!(
        organization_id: organization_id,
        event_type: event_type,
        event_id: payload[:email_id] || payload[:delivery_id] || SecureRandom.uuid,
        request_body: payload.to_json,
        status: "pending"
      )

      WebhookDeliveryWorker.perform_async(delivery.id)
    end
  end

  private

  def uri
    @uri ||= URI.parse(@webhook.url)
  end

  def build_payload
    {
      id: @webhook_delivery.event_id,
      type: @webhook_delivery.event_type,
      created_at: Time.current.iso8601(3),
      data: JSON.parse(@webhook_delivery.request_body || "{}")
    }
  rescue JSON::ParserError
    {
      id: @webhook_delivery.event_id,
      type: @webhook_delivery.event_type,
      created_at: Time.current.iso8601(3),
      data: {}
    }
  end
end
