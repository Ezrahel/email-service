module Providers
  class AdapterRegistry
    @adapters = {}
    @mutex = Mutex.new

    class << self
      def register(provider_type, adapter_class)
        @mutex.synchronize do
          @adapters[provider_type.to_s] = adapter_class
        end
      end

      def get(provider_type)
        @mutex.synchronize do
          @adapters[provider_type.to_s] || raise(
            Providers::Errors::ConfigurationError,
            "No adapter registered for provider type: #{provider_type}"
          )
        end
      end

      def registered_types
        @mutex.synchronize { @adapters.keys.dup }
      end

      def registered?(provider_type)
        @mutex.synchronize { @adapters.key?(provider_type.to_s) }
      end

      def load_all!
        require_dependencies
        register_built_in_adapters
      end

      private

      def require_dependencies
        Dir[Rails.root.join("app/services/providers/adapters/*_adapter.rb")].sort.each do |f|
          require_dependency f
        end
      end

      def register_built_in_adapters
        register("ses", Providers::Adapters::SesAdapter)
        register("sendgrid", Providers::Adapters::SendgridAdapter)
        register("mailgun", Providers::Adapters::MailgunAdapter)
        register("postmark", Providers::Adapters::PostmarkAdapter)
        register("smtp", Providers::Adapters::SmtpAdapter)
      end
    end
  end
end
