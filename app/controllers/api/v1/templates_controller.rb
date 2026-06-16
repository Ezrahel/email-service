module Api
  module V1
    class TemplatesController < BaseController
      before_action :require_template_scope!
      before_action :set_template, only: %i[show update destroy send]

      def index
        templates = current_organization.templates
          .order(created_at: :desc)

        records, pagy = paginate(templates)
        render_collection(records, TemplateSerializer, meta: pagy_meta(pagy))
      end

      def create
        require_scope!("template:manage")

        form = CreateTemplateForm.new(template_params.merge(organization: current_organization))

        unless form.valid?
          raise Errors::ValidationError, details: form.errors.messages
        end

        template = current_organization.templates.create!(form.attributes)
        template.create_version!(user: current_user)

        render_success(
          TemplateSerializer.new(template).serializable_hash[:data],
          status: :created
        )
      end

      def show
        render_success TemplateSerializer.new(@template).serializable_hash[:data]
      end

      def update
        require_scope!("template:manage")

        @template.update!(template_params)

        if should_create_version?
          @template.create_version!(user: current_user, change_notes: params[:change_notes])
        end

        render_success TemplateSerializer.new(@template.reload).serializable_hash[:data]
      end

      def destroy
        require_scope!("template:manage")

        @template.soft_delete
        render_success(message: "Template deleted")
      end

      def send
        require_scope!("email:send")

        result = Templates::SendTemplate.call(
          organization: current_organization,
          template: @template,
          params: send_template_params
        )

        render_success(
          EmailSerializer.new(result.email).serializable_hash[:data],
          status: :created
        )
      end

      private

      def set_template
        @template = current_organization.templates.find(params[:id])
      end

      def template_params
        params.permit(:name, :slug, :subject, :html_body, :text_body, :description, variables: %i[name type required])
      end

      def send_template_params
        params.permit(:from, to: [], cc: [], bcc: [], variables: {})
      end

      def should_create_version?
        params[:subject].present? || params[:html_body].present? || params[:text_body].present?
      end

      def require_template_scope!
        require_scope!("template:manage")
      rescue Errors::ForbiddenError
        raise unless action_name.in?(%w[index show])
      end

      def pagy_meta(pagy)
        { page: pagy.page, per_page: pagy.items, total: pagy.count, pages: pagy.pages }
      end
    end
  end
end
