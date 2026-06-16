module Api
  module V1
    class ApiKeysController < BaseController
      before_action :require_api_key_scope!
      before_action :set_api_key, only: %i[show destroy revoke]

      def index
        keys = current_organization.api_keys
          .order(created_at: :desc)

        records, pagy = paginate(keys)
        render_collection(records, ApiKeySerializer, meta: pagy_meta(pagy))
      end

      def create
        require_scope!("api_key:manage")

        full_key = ApiKey.create_with_key!(
          organization: current_organization,
          user: current_user,
          name: params[:name],
          scopes: params[:scopes] || [],
          allowed_ips: params[:allowed_ips] || [],
          expires_at: params[:expires_at]&.then { |t| Time.parse(t) }
        )

        key_record = current_organization.api_keys.find_by!(key_last_chars: full_key.last(4))

        render_success(
          ApiKeySerializer.new(key_record).serializable_hash[:data]
            .merge(full_key: full_key),
          status: :created
        )
      end

      def show
        render_success ApiKeySerializer.new(@api_key).serializable_hash[:data]
      end

      def destroy
        require_scope!("api_key:manage")

        @api_key.soft_delete
        render_success(message: "API key deleted")
      end

      def revoke
        require_scope!("api_key:manage")

        @api_key.revoke!
        render_success(message: "API key revoked")
      end

      private

      def set_api_key
        @api_key = current_organization.api_keys.find(params[:id])
      end

      def require_api_key_scope!
        require_scope!("api_key:manage")
      rescue Errors::ForbiddenError
        raise unless action_name.in?(%w[index show])
      end

      def pagy_meta(pagy)
        { page: pagy.page, per_page: pagy.items, total: pagy.count, pages: pagy.pages }
      end
    end
  end
end
