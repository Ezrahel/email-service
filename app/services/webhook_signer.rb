class WebhookSigner
  SIGNATURE_VERSION = "v1"

  class << self
    def sign(payload, secret)
      timestamp = Time.current.to_i
      signature_data = "#{timestamp}.#{payload.to_json}"
      signature = OpenSSL::HMAC.hexdigest("SHA256", secret, signature_data)

      "#{SIGNATURE_VERSION}=#{signature}"
    end

    def verify(payload, signature, secret)
      return false if signature.blank?

      version, actual_sig = signature.split("=", 2)

      expected = OpenSSL::HMAC.hexdigest("SHA256", secret, payload.to_json)

      secure_compare(actual_sig.to_s, expected)
    end

    def verify_with_timestamp(payload, signature, secret, max_age: 5.minutes)
      return false unless signature&.start_with?("#{SIGNATURE_VERSION}=")

      timestamp_str, actual_sig = signature.sub("#{SIGNATURE_VERSION}=", "").split(".", 2)
      return false unless timestamp_str && actual_sig

      timestamp = timestamp_str.to_i
      return false if Time.current.to_i - timestamp > max_age.to_i

      expected = OpenSSL::HMAC.hexdigest("SHA256", secret, "#{timestamp}.#{payload.to_json}")

      secure_compare(actual_sig, expected)
    end

    private

    def secure_compare(a, b)
      ActiveSupport::SecurityUtils.secure_compare(a.to_s, b.to_s)
    end
  end
end
