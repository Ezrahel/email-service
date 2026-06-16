class Rack::Attack
  # Throttle all requests by IP
  throttle("req/ip", limit: ENV.fetch("RATE_LIMIT_API_REQUESTS_PER_MINUTE", 300).to_i, period: 1.minute) do |req|
    req.ip
  end

  # Throttle email sends per API key
  throttle("emails/api_key", limit: ENV.fetch("RATE_LIMIT_EMAILS_PER_SECOND", 50).to_i, period: 1.second) do |req|
    req.env["HTTP_AUTHORIZATION"]
  end

  # Throttle email sends per API key (daily)
  throttle("emails/api_key/day", limit: ENV.fetch("RATE_LIMIT_EMAILS_PER_DAY", 10_000).to_i, period: 1.day) do |req|
    req.env["HTTP_AUTHORIZATION"]
  end

  # Block IPs that exceed a high threshold
  blocklist("block/abusive_ips") do |req|
    Rack::Attack::Allow2Block.new(ENV.fetch("RATE_LIMIT_BLOCK_THRESHOLD", 1000).to_i, 1.hour).blocklisted?(req.ip)
  end

  # Custom throttle response
  self.throttled_responder = lambda do |req|
    match_data = req.env["rack.attack.match_data"]
    now = match_data[:epoch_time]
    retry_after = match_data[:period] - (now % match_data[:period])

    [
      429,
      {
        "Content-Type" => "application/json",
        "Retry-After" => retry_after.to_s,
        "X-RateLimit-Limit" => match_data[:limit].to_s,
        "X-RateLimit-Remaining" => "0",
        "X-RateLimit-Reset" => (now + retry_after).to_s
      },
      [{ error: "Rate limit exceeded", retry_after: retry_after }.to_json]
    ]
  end
end
