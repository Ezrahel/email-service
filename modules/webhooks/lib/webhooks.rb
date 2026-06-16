require "webhooks/engine"

module Webhooks
  # Webhook event delivery system.
  #
  # Responsibilities:
  # - Event publishing (email.sent, delivered, opened, clicked, failed, bounced)
  # - HTTP delivery with retries
  # - Signature verification (HMAC-SHA256)
  # - Replay protection (idempotency keys)
  # - Webhook logs and delivery history
  # - Endpoint management per project
end
