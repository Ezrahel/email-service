module Api
  module V1
    class WebhooksController < BaseController
      before_action :require_webhook_scope!
      before_action :set_webhook, only: %i[show update destroy test]

      def index
        webhooks = current_organization.webhooks
          .order(created_at: :desc)

        records, pagy = paginate(webhooks)
        render_collection(records, WebhookSerializer, meta: pagy_meta(pagy))
      end

      def create
        require_scope!("webhook:manage")

        form = CreateWebhookForm.new(webhook_params.merge(organization: current_organization))

        unless form.valid?
          raise Errors::ValidationError, details: form.errors.messages
        end

        webhook = current_organization.webhooks.create!(form.attributes) do |w|
          w.secret = SecureRandom.hex(32)
        end

        render_success(
          WebhookSerializer.new(webhook).serializable_hash[:data],
          status: :created
        )
      end

      def show
        render_success WebhookSerializer.new(@webhook).serializable_hash[:data]
      end

      def update
        require_scope!("webhook:manage")

        @webhook.update!(webhook_params)
        render_success WebhookSerializer.new(@webhook.reload).serializable_hash[:data]
      end

      def destroy
        require_scope!("webhook:manage")

        @webhook.soft_delete
        render_success(message: "Webhook deleted")
      end

      def test
        require_scope!("webhook:manage")

        Webhooks::TestDelivery.call(webhook: @webhook)
        render_success(message: "Test event sent")
      end

      private

      def set_webhook
        @webhook = current_organization.webhooks.find(params[:id])
      end

      def webhook_params
        params.permit(:name, :url, :api_version, :is_active, events: [])
      end

      def require_webhook_scope!
        require_scope!("webhook:manage")
      rescue Errors::ForbiddenError
        raise unless action_name.in?(%w[index show])
      end

      def pagy_meta(pagy)
        { page: pagy.page, per_page: pagy.items, total: pagy.count, pages: pagy.pages }
      end
    end
  end
end
