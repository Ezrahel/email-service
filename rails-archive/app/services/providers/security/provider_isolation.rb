module Providers
  module Security
    class ProviderIsolation
      ISOLATION_LEVELS = %w[none tenant_only provider_only full].freeze

      class << self
        def isolate!(provider_config)
          level = isolation_level(provider_config)
          case level
          when "tenant_only" then isolate_tenant(provider_config)
          when "provider_only" then isolate_provider(provider_config)
          when "full" then isolate_full(provider_config)
          else false
          end
        end

        def isolation_level(provider_config)
          provider_config.settings&.dig("isolation_level") ||
            ENV.fetch("PROVIDER_ISOLATION_LEVEL", "none")
        end

        def sandboxed_credentials(provider_config)
          return provider_config.credentials unless isolation_required?(provider_config)

          case isolation_level(provider_config)
          when "tenant_only"
            scoped_tenant_credentials(provider_config)
          when "provider_only"
            scoped_provider_credentials(provider_config)
          when "full"
            scoped_full_credentials(provider_config)
          else
            provider_config.credentials
          end
        end

        private

        def isolation_required?(provider_config)
          level = isolation_level(provider_config)
          level != "none"
        end

        def isolate_tenant(provider_config)
          key = "iso:tenant:#{provider_config.organization_id}:#{provider_config.provider_type}"
          existing = REDIS_POOL.with { |c| c.get(key) }
          return false if existing

          rotated_creds = rotate_credentials(provider_config.credentials)
          REDIS_POOL.with { |c| c.setex(key, 86_400, rotated_creds.to_json) }
          true
        end

        def isolate_provider(provider_config)
          key = "iso:provider:#{provider_config.provider_type}"
          existing = REDIS_POOL.with { |c| c.get(key) }
          return false if existing

          REDIS_POOL.with { |c| c.setex(key, 86_400, "isolated") }
          true
        end

        def isolate_full(provider_config)
          isolate_tenant(provider_config) || isolate_provider(provider_config)
        end

        def scoped_tenant_credentials(provider_config)
          key = "iso:tenant:#{provider_config.organization_id}:#{provider_config.provider_type}"
          cached = REDIS_POOL.with { |c| c.get(key) }
          cached ? JSON.parse(cached) : provider_config.credentials
        rescue JSON::ParserError
          provider_config.credentials
        end

        def scoped_provider_credentials(provider_config)
          provider_config.credentials
        end

        def scoped_full_credentials(provider_config)
          scoped_tenant_credentials(provider_config)
        end

        def rotate_credentials(credentials)
          credentials.transform_values do |v|
            v.is_a?(String) && v.length > 8 ? "#{v[0..3]}_rotated_#{SecureRandom.hex(4)}" : v
          end
        end
      end
    end
  end
end
