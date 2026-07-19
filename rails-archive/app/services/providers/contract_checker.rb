module Providers
  class ContractChecker
    REQUIRED_METHODS = %i[send_email send_batch cancel_delivery check_status health_check validate_domain estimate_cost].freeze

    class << self
      def verify!(adapter_class)
        missing = REQUIRED_METHODS.select { |m| !adapter_class.method_defined?(m) }

        if missing.any?
          raise Providers::Errors::ConfigurationError,
            "#{adapter_class.name} is missing required methods: #{missing.join(', ')}"
        end

        true
      end

      def verify_instance!(adapter)
        verify!(adapter.class)
      end

      def contract_summary(adapter_class)
        REQUIRED_METHODS.each_with_object({}) do |method, summary|
          summary[method] = adapter_class.method_defined?(method)
        end
      end
    end
  end
end
