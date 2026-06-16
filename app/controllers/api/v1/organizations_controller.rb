module Api
  module V1
    class OrganizationsController < BaseController
      def show
        render_success OrganizationSerializer.new(current_organization).serializable_hash[:data]
      end

      def update
        require_scope!("organization:manage")

        current_organization.update!(org_params)
        render_success OrganizationSerializer.new(current_organization.reload).serializable_hash[:data]
      end

      private

      def org_params
        params.permit(:name, :billing_email, :timezone)
      end
    end
  end
end
