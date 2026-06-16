class RetryPolicy
  BASE_DELAY = 10.seconds
  MAX_DELAY = 24.hours
  MAX_RETRIES = 5
  JITTER_RANGE = 0..5

  class << self
    def delay_for(attempt)
      return 0 if attempt <= 0

      delay = [BASE_DELAY * (2 ** (attempt - 1)), MAX_DELAY].min
      delay + rand(JITTER_RANGE).seconds
    end

    def max_attempts
      MAX_RETRIES
    end

    def retryable?(attempt, error_class: nil)
      return false if attempt >= MAX_RETRIES

      non_retryable = %w[
        Errors::ValidationError Errors::AuthError Errors::ForbiddenError
        Errors::NotFoundError Errors::QuotaExceededError
      ]

      return false if error_class && non_retryable.include?(error_class)

      true
    end

    def should_dead_letter?(attempt, error_class: nil)
      !retryable?(attempt, error_class: error_class)
    end
  end
end
