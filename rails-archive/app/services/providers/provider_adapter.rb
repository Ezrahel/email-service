module Providers
  class ProviderAdapter
    attr_reader :provider_config, :provider_type, :transport

    def initialize(provider_config)
      @provider_config = provider_config
      @provider_type = self.class.name.demodulize.gsub("Adapter", "").underscore
      @transport = build_transport
      validate_configuration!
    end

    def send_email(email_message)
      raise NotImplementedError, "#{self.class}#send_email must be implemented"
    end

    def send_batch(email_messages)
      raise NotImplementedError, "#{self.class}#send_batch must be implemented"
    end

    def cancel_delivery(provider_message_id)
      raise NotImplementedError, "#{self.class}#cancel_delivery must be implemented"
    end

    def check_status(provider_message_id)
      raise NotImplementedError, "#{self.class}#check_status must be implemented"
    end

    def health_check
      raise NotImplementedError, "#{self.class}#health_check must be implemented"
    end

    def validate_domain(domain)
      raise NotImplementedError, "#{self.class}#validate_domain must be implemented"
    end

    def estimate_cost(email_message)
      raise NotImplementedError, "#{self.class}#estimate_cost must be implemented"
    end

    def test
      health_check
    end

    def max_retries
      3
    end

    def timeout_ms
      provider_config.settings&.dig("timeout_ms") || 10_000
    end

    def rate_limit_threshold
      provider_config.settings&.dig("rate_limit") || 10
    end

    def rate_limit_period
      provider_config.settings&.dig("rate_limit_period") || 1
    end

    def provider_metadata
      {
        type: provider_type,
        max_retries: max_retries,
        timeout_ms: timeout_ms,
        rate_limit: rate_limit_threshold,
        supports_batch: supports_batch?,
        supports_cancel: supports_cancel?,
        supports_status_check: supports_status_check?,
        supports_tracking: supports_tracking?,
        supports_tags: supports_tags?,
        supports_templates: supports_templates?,
        supports_attachments: supports_attachments?,
        max_attachment_size_mb: max_attachment_size_mb,
        max_recipients_per_batch: max_recipients_per_batch
      }
    end

    def supports_batch?
      false
    end

    def supports_cancel?
      false
    end

    def supports_status_check?
      true
    end

    def supports_tracking?
      true
    end

    def supports_tags?
      true
    end

    def supports_templates?
      false
    end

    def supports_attachments?
      true
    end

    def max_attachment_size_mb
      25
    end

    def max_recipients_per_batch
      50
    end

    private

    def build_transport
      raise NotImplementedError, "#{self.class}#build_transport must be implemented"
    end

    def validate_configuration!
      raise Providers::Errors::ConfigurationError, "Missing credentials for #{provider_type}" if provider_config.credentials.blank?
    end

    def with_timing
      start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      result = yield
      duration = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - start) * 1000).round(2)
      [result, duration]
    end

    def normalize_response(response)
      raise NotImplementedError, "#{self.class}#normalize_response must be implemented"
    end
  end
end
