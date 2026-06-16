module Providers
  module Security
    class EncryptedConfiguration
      ENCRYPTED_FIELDS = %w[credentials signing_key api_key password secret_access_key api_token].freeze

      class << self
        def encrypt_provider_config!(provider_config)
          payload = provider_config.credentials.to_json
          encrypted = CredentialStore.encrypt(payload)

          provider_config.update_column(:encrypted_credentials, encrypted)

          EventPublisher.publish(
            event_type: "provider.config_encrypted",
            organization_id: provider_config.organization_id,
            payload: {
              provider_config_id: provider_config.id,
              provider_type: provider_config.provider_type
            }
          )

          true
        end

        def decrypt_provider_config(provider_config)
          encrypted = provider_config.respond_to?(:encrypted_credentials) ?
            provider_config.encrypted_credentials : nil

          return provider_config.credentials unless encrypted.present?

          CredentialStore.decrypt(encrypted) || provider_config.credentials
        rescue StandardError => e
          Rails.logger.warn "Config decryption failed for #{provider_config.id}: #{e.message}"
          provider_config.credentials
        end

        def rotate_config_key!
          old_key = ENV["CREDENTIAL_ENCRYPTION_KEY"]
          new_key = SecureRandom.hex(32)

          ProviderConfig.find_each do |config|
            decrypted = decrypt_provider_config(config)
            next unless decrypted

            TempPublicKey = new_key
            encrypt_provider_config!(config)
          end

          ENV["CREDENTIAL_ENCRYPTION_KEY"] = new_key
          old_key
        end

        def masked_credentials(credentials)
          return {} unless credentials.is_a?(Hash)

          credentials.each_with_object({}) do |(key, value), masked|
            masked[key] = if ENCRYPTED_FIELDS.include?(key.to_s) && value.is_a?(String)
              "#{value[0..3]}****#{value[-4..]}"
            else
              value
            end
          end
        end
      end
    end
  end
end
