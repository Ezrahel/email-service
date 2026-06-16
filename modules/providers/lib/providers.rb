require "providers/engine"

module Providers
  # Email provider abstraction layer with adapter pattern.
  #
  # Responsibilities:
  # - Provider adapter interface
  # - SES, SendGrid, Mailgun, Postmark, SMTP adapters
  # - Provider routing (weighted, failover)
  # - Circuit breaker per provider
  # - Health scoring
  # - Provider throttling
  # - Domain verification (SPF, DKIM, DMARC)
end
