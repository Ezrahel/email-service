module Api
  module V1
    class AuthController < BaseController
      skip_before_action :authenticate!, only: %i[login refresh]
      skip_before_action :set_organization_context, only: %i[login refresh logout]

      def login
        result = AuthService.authenticate_user(
          email: params[:email],
          password: params[:password]
        )

        unless result.success?
          raise Errors::AuthError, result.error
        end

        render_success(
          token: result.token,
          refresh_token: result.refresh_token,
          expires_at: result.expires_at,
          user: UserSerializer.new(result.user).serializable_hash[:data]
        )
      end

      def refresh
        result = AuthService.refresh_token(params[:refresh_token])

        unless result.success?
          raise Errors::AuthError, result.error
        end

        render_success(
          token: result.token,
          expires_at: result.expires_at
        )
      end

      def logout
        AuthService.revoke_token(current_api_key)
        render_success(message: "Logged out successfully")
      end
    end
  end
end
