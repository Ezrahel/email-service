module Providers
  module Errors
    class ProviderError < StandardError
      attr_reader :original_error, :provider_type, :retryable

      def initialize(message = nil, original_error: nil, provider_type: nil, retryable: true)
        @original_error = original_error
        @provider_type = provider_type
        @retryable = retryable
        super(message || original_error&.message)
      end
    end

    class ConnectionError < ProviderError
      def initialize(message = "Provider connection failed", **kwargs)
        super(message, **kwargs)
      end
    end

    class TimeoutError < ProviderError
      def initialize(message = "Provider request timed out", **kwargs)
        super(message, **kwargs)
      end
    end

    class RateLimitError < ProviderError
      attr_reader :retry_after

      def initialize(message = "Rate limit exceeded", retry_after: nil, **kwargs)
        @retry_after = retry_after
        super(message, **kwargs)
      end
    end

    class AuthenticationError < ProviderError
      def initialize(message = "Provider authentication failed", **kwargs)
        super(message, retryable: false, **kwargs)
      end
    end

    class InvalidRequestError < ProviderError
      def initialize(message = "Invalid request", **kwargs)
        super(message, retryable: false, **kwargs)
      end
    end

    class QuotaExceededError < ProviderError
      def initialize(message = "Provider quota exceeded", **kwargs)
        super(message, retryable: false, **kwargs)
      end
    end

    class BounceError < ProviderError
      attr_reader :bounce_type, :bounce_classification

      def initialize(message = "Email bounced", bounce_type: nil, bounce_classification: nil, **kwargs)
        @bounce_type = bounce_type
        @bounce_classification = bounce_classification
        super(message, retryable: false, **kwargs)
      end
    end

    class RejectionError < ProviderError
      def initialize(message = "Email rejected", **kwargs)
        super(message, retryable: false, **kwargs)
      end
    end

    class ConfigurationError < ProviderError
      def initialize(message = "Provider configuration error", **kwargs)
        super(message, **kwargs)
      end
    end
  end
end
