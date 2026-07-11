module Api
  module V1
    class BaseController < ApplicationController
      include ErrorHandler
      include Pagy::Backend

      before_action :authenticate!
      before_action :check_rate_limit!
      before_action :set_organization_context

      private

      def authenticate!
        @auth_result = AuthService.authenticate(request)

        unless @auth_result.success?
          raise AuthError, @auth_result.error
        end

        Current.user_id = @auth_result.user&.id
        Current.organization_id = @auth_result.organization&.id
        Current.api_key_id = @auth_result.api_key&.id
      end

      def check_rate_limit!
        key = @auth_result&.api_key&.id || request.ip
        limiter = RateLimiter.new(key)

        unless limiter.allow?
          raise RateLimitError, retry_after: limiter.retry_after
        end
      end

      def set_organization_context
        @organization = Current.organization_id &&
          Organization.find_by(id: Current.organization_id)

        raise ForbiddenError, "No organization context" unless @organization
      end

      def current_user
        @auth_result&.user
      end

      def current_organization
        @organization
      end

      def current_api_key
        @auth_result&.api_key
      end

      def require_scope!(scope)
        return true if current_api_key&.scopes&.include?(scope)

        raise ForbiddenError, "Missing required scope: #{scope}"
      end

      def paginate(scope)
        pagy, records = pagy(scope, items: params.fetch(:per_page, 50).to_i)
        [records, pagy]
      end
    end
  end
end
