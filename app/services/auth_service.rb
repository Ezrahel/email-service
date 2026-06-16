class AuthService
  class Result
    attr_reader :user, :organization, :api_key, :error,
                :token, :refresh_token, :expires_at

    def initialize(success:, user: nil, organization: nil, api_key: nil,
                   error: nil, token: nil, refresh_token: nil, expires_at: nil)
      @success = success
      @user = user
      @organization = organization
      @api_key = api_key
      @error = error
      @token = token
      @refresh_token = refresh_token
      @expires_at = expires_at
    end

    def success?
      @success
    end
  end

  JWT_ALGORITHM = "RS256"
  ACCESS_TOKEN_TTL = ENV.fetch("JWT_ACCESS_TOKEN_TTL", 900).to_i.seconds
  REFRESH_TOKEN_TTL = ENV.fetch("JWT_REFRESH_TOKEN_TTL", 604800).to_i.seconds

  class << self
    def authenticate(request)
      token = extract_token(request)
      return Result.new(success: false, error: "Missing API key") unless token

      key_digest = Digest::SHA256.hexdigest(token)
      api_key = ApiKey.active.find_by(key_digest: key_digest)

      return Result.new(success: false, error: "Invalid API key") unless api_key
      return Result.new(success: false, error: "API key expired") if api_key.expired?

      api_key.touch(:last_used_at)

      Result.new(
        success: true,
        user: api_key.user,
        organization: api_key.organization,
        api_key: api_key
      )
    end

    def authenticate_user(email:, password:)
      user = User.active.find_by(email: email)

      unless user&.authenticate(password)
        user&.increment_failed_attempts!
        return Result.new(success: false, error: "Invalid email or password")
      end

      if user.status == "locked"
        return Result.new(success: false, error: "Account locked. Try again later.")
      end

      user.record_login!(ip: nil)

      token, expires_at = generate_access_token(user)
      refresh_token = generate_refresh_token(user)

      Result.new(
        success: true,
        user: user,
        organization: user.organizations.first,
        token: token,
        refresh_token: refresh_token,
        expires_at: expires_at
      )
    end

    def refresh_token(refresh_token)
      payload = decode_token(refresh_token)
      return Result.new(success: false, error: "Invalid or expired refresh token") unless payload

      user = User.active.find_by(id: payload["sub"])
      return Result.new(success: false, error: "User not found") unless user

      token, expires_at = generate_access_token(user)

      Result.new(
        success: true,
        user: user,
        token: token,
        expires_at: expires_at
      )
    rescue JWT::DecodeError
      Result.new(success: false, error: "Invalid refresh token")
    end

    def revoke_token(api_key)
      # For JWT, revocation is handled by short TTL.
      # For API keys, the key itself is the credential.
      # Additional revocation could be added via a blocklist.
      true
    end

    private

    def extract_token(request)
      header = request.authorization
      return nil unless header

      match = header.match(/\ABearer\s+(.+)\z/)
      match ? match[1] : nil
    end

    def generate_access_token(user)
      expires_at = Time.current + ACCESS_TOKEN_TTL
      payload = {
        sub: user.id,
        email: user.email,
        exp: expires_at.to_i,
        iat: Time.current.to_i,
        type: "access"
      }

      [JWT.encode(payload, jwt_secret, JWT_ALGORITHM), expires_at]
    end

    def generate_refresh_token(user)
      payload = {
        sub: user.id,
        exp: (Time.current + REFRESH_TOKEN_TTL).to_i,
        iat: Time.current.to_i,
        type: "refresh",
        jti: SecureRandom.uuid
      }

      JWT.encode(payload, jwt_secret, JWT_ALGORITHM)
    end

    def decode_token(token)
      decoded = JWT.decode(token, jwt_secret, true, { algorithm: JWT_ALGORITHM })
      decoded.first
    rescue JWT::ExpiredSignature, JWT::DecodeError
      nil
    end

    def jwt_secret
      @jwt_secret ||= begin
        key = ENV["JWT_SECRET"]
        if key&.include?("BEGIN RSA PRIVATE KEY")
          OpenSSL::PKey::RSA.new(key)
        else
          key || "fallback-secret-do-not-use-in-production"
        end
      end
    end
  end
end
