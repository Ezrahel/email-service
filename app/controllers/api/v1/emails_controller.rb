module Api
  module V1
    class EmailsController < BaseController
      before_action :require_email_scope!

      def create
        require_scope!("email:send")

        form = SendEmailForm.new(email_params.merge(organization: current_organization))

        unless form.valid?
          raise Errors::ValidationError, details: form.errors.messages
        end

        result = Emails::SendEmail.call(
          organization: current_organization,
          params: form.attributes,
          idempotency_key: params[:idempotency_key],
          api_key: current_api_key
        )

        render_success(
          EmailSerializer.new(result.email).serializable_hash[:data],
          status: :created
        )
      end

      def show
        require_scope!("email:read")

        email = current_organization.email_messages.find(params[:id])
        render_success EmailSerializer.new(email).serializable_hash[:data]
      end

      def index
        require_scope!("email:read")

        emails = current_organization.email_messages
          .order(created_at: :desc)
          .then { |scope| apply_filters(scope) }

        records, pagy = paginate(emails)
        render_collection(records, EmailSerializer, meta: pagy_meta(pagy))
      end

      def batch
        require_scope!("email:send")

        messages = params[:messages] || []
        raise Errors::ValidationError, "No messages provided" if messages.empty?
        raise Errors::ValidationError, "Batch limit is 1000" if messages.size > 1000

        result = Emails::SendBatch.call(
          organization: current_organization,
          messages: messages,
          api_key: current_api_key
        )

        render_success(
          batch_id: result.batch_id,
          total: result.total,
          accepted: result.accepted,
          rejected: result.rejected
        )
      end

      def validate
        form = SendEmailForm.new(email_params.merge(organization: current_organization))

        if form.valid?
          render_success(valid: true)
        else
          render_success(valid: false, errors: form.errors.messages)
        end
      end

      private

      def email_params
        params.permit(
          :from, :subject, :html, :text, :reply_to, :idempotency_key, :scheduled_at,
          to: [], cc: [], bcc: [],
          headers: {},
          tags: []
        )
      end

      def apply_filters(scope)
        scope = scope.where(status: params[:status]) if params[:status].present?
        scope = scope.where(to: params[:to]) if params[:to].present?
        scope = scope.where("created_at >= ?", params[:since]) if params[:since].present?
        scope = scope.where("created_at <= ?", params[:until]) if params[:until].present?
        scope
      end

      def require_email_scope!
        require_scope!("email:send")
      rescue Errors::ForbiddenError
        # Allow read-only access for index/show
        raise unless action_name.in?(%w[index show])
      end

      def pagy_meta(pagy)
        { page: pagy.page, per_page: pagy.items, total: pagy.count, pages: pagy.pages }
      end
    end
  end
end
