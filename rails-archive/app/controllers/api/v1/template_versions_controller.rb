module Api
  module V1
    class TemplateVersionsController < BaseController
      before_action :set_template

      def index
        versions = @template.versions.order(version: :desc)
        render_success(
          versions.map { |v| TemplateVersionSerializer.new(v).serializable_hash[:data] }
        )
      end

      def show
        version = @template.versions.find_by!(version: params[:id])
        render_success TemplateVersionSerializer.new(version).serializable_hash[:data]
      end

      def create
        require_scope!("template:manage")

        version = @template.create_version!(
          user: current_user,
          change_notes: params[:change_notes]
        )

        render_success(
          TemplateVersionSerializer.new(version).serializable_hash[:data],
          status: :created
        )
      end

      private

      def set_template
        @template = current_organization.templates.find(params[:template_id])
      end
    end
  end
end
