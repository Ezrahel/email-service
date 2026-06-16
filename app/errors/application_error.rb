module Errors
  class ApplicationError < StandardError
    attr_reader :code, :status, :details

    def initialize(message = nil, code: nil, status: nil, details: {})
      @code = code || self.class.name.demodulize.underscore
      @status = status || 500
      @details = details
      super(message || default_message)
    end

    def to_h
      {
        error: {
          code: code,
          message: message,
          details: details.presence
        }.compact
      }
    end

    def default_message
      "An unexpected error occurred"
    end
  end

  class ValidationError < ApplicationError
    def initialize(message = "Validation failed", details: {})
      super(message, code: "validation_error", status: 422, details: details)
    end
  end

  class AuthError < ApplicationError
    def initialize(message = "Authentication failed")
      super(message, code: "auth_error", status: 401)
    end
  end

  class ForbiddenError < ApplicationError
    def initialize(message = "Forbidden")
      super(message, code: "forbidden", status: 403)
    end
  end

  class NotFoundError < ApplicationError
    def initialize(message = "Resource not found")
      super(message, code: "not_found", status: 404)
    end
  end

  class RateLimitError < ApplicationError
    attr_reader :retry_after

    def initialize(retry_after: 1)
      @retry_after = retry_after
      super("Rate limit exceeded", code: "rate_limit_exceeded", status: 429,
            details: { retry_after: retry_after })
    end
  end

  class ProviderError < ApplicationError
    def initialize(message = "Provider error", details: {})
      super(message, code: "provider_error", status: 502, details: details)
    end
  end

  class IdempotencyError < ApplicationError
    def initialize(message = "Idempotency key conflict")
      super(message, code: "idempotency_conflict", status: 409)
    end
  end

  class QuotaExceededError < ApplicationError
    def initialize(message = "Monthly email quota exceeded")
      super(message, code: "quota_exceeded", status: 429)
    end
  end

  class UnprocessableError < ApplicationError
    def initialize(message = "Unprocessable entity", details: {})
      super(message, code: "unprocessable", status: 422, details: details)
    end
  end
end
