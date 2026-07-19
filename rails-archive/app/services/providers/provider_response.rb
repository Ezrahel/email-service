module Providers
  class ProviderResponse
    attr_reader :provider_message_id, :status, :raw_response, :duration_ms,
                :error_code, :error_message, :retryable, :metadata

    def initialize(provider_message_id: nil, status:, raw_response: nil,
                   duration_ms: 0, error_code: nil, error_message: nil,
                   retryable: false, metadata: {})
      @provider_message_id = provider_message_id
      @status = status
      @raw_response = raw_response
      @duration_ms = duration_ms
      @error_code = error_code
      @error_message = error_message
      @retryable = retryable
      @metadata = metadata
    end

    def success?
      status == "delivered"
    end

    def failed?
      %w[failed rejected bounced].include?(status)
    end

    def retryable_failure?
      failed? && retryable
    end

    def ==(other)
      return false unless other.is_a?(ProviderResponse)
      provider_message_id == other.provider_message_id && status == other.status
    end

    def to_h
      {
        provider_message_id: provider_message_id,
        status: status,
        duration_ms: duration_ms,
        error_code: error_code,
        error_message: error_message,
        retryable: retryable
      }
    end

    def self.delivered(message_id:, duration_ms: 0, raw_response: nil, metadata: {})
      new(
        provider_message_id: message_id,
        status: "delivered",
        duration_ms: duration_ms,
        raw_response: raw_response,
        metadata: metadata
      )
    end

    def self.failed(error_message:, error_code: nil, retryable: true, duration_ms: 0, raw_response: nil)
      new(
        status: "failed",
        error_message: error_message,
        error_code: error_code,
        retryable: retryable,
        duration_ms: duration_ms,
        raw_response: raw_response
      )
    end

    def self.bounced(error_message:, error_code: nil, duration_ms: 0, raw_response: nil)
      new(
        status: "bounced",
        error_message: error_message,
        error_code: error_code,
        retryable: false,
        duration_ms: duration_ms,
        raw_response: raw_response
      )
    end

    def self.rejected(error_message:, error_code: nil, duration_ms: 0, raw_response: nil)
      new(
        status: "rejected",
        error_message: error_message,
        error_code: error_code,
        retryable: false,
        duration_ms: duration_ms,
        raw_response: raw_response
      )
    end
  end
end
