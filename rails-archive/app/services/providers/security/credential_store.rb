module Providers
  module Security
    class CredentialStore
      class << self
        def encrypt(credentials)
          encryptor.encrypt_and_sign(credentials.to_json)
        end

        def decrypt(encrypted_data)
          json = encryptor.decrypt_and_sign(encrypted_data)
          JSON.parse(json)
        rescue ActiveSupport::MessageEncryptor::InvalidMessage,
               ActiveSupport::MessageVerifier::InvalidSignature
          nil
        end

        def rotate!(provider_config, new_credentials)
          old_credentials = provider_config.credentials

          provider_config.update!(credentials: new_credentials)

          EventPublisher.publish(
            event_type: "provider.credentials_rotated",
            organization_id: provider_config.organization_id,
            payload: {
              provider_config_id: provider_config.id,
              provider_type: provider_config.provider_type,
              rotated_at: Time.current.iso8601
            }
          )

          AuditLog.create!(
            organization_id: provider_config.organization_id,
            action: "provider_credentials_rotated",
            auditable: provider_config,
            auditable_type: "ProviderConfig",
            changes: {
              old: { keys: old_credentials&.keys },
              new: { keys: new_credentials.keys }
            }
          )

          true
        rescue ActiveRecord::RecordInvalid => e
          Rails.logger.error "Credential rotation failed: #{e.message}"
          false
        end

        def validate_format!(credentials)
          raise ArgumentError, "Credentials must be a Hash" unless credentials.is_a?(Hash)
          raise ArgumentError, "Credentials cannot be empty" if credentials.empty?

          sensitive_keys = %w[api_key password secret_access_key api_token]
          credentials.each do |key, value|
            if sensitive_keys.include?(key.to_s) && (value.nil? || value.to_s.strip.empty?)
              raise ArgumentError, "#{key} cannot be blank"
            end
          end

          true
        end

        private

        def encryptor
          key = ENV.fetch("CREDENTIAL_ENCRYPTION_KEY", Rails.application.secret_key_base[0..31])
          ActiveSupport::MessageEncryptor.new(key, cipher: "aes-256-gcm")
        end
      end
    end
  end
end
