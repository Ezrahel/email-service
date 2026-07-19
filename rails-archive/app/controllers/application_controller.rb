require_dependency "application_error"

class ApplicationController < ActionController::API
  include ActionController::MimeResponds
  include Pagy::Backend

  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
  rescue_from ActionController::ParameterMissing, with: :bad_request
  rescue_from ::RateLimitError, with: :too_many_requests

  before_action :set_request_attributes

  # ── Auth Context ────────────────────────────────────────────
  attr_reader :current_user, :current_organization, :current_api_key

  private

  def set_request_attributes
    Current.request_id = request.request_id
    Current.user_id = current_user&.id
    Current.organization_id = current_organization&.id
  end

  def check_ip_allowlist
    return unless current_organization&.ip_allowlist_enabled?

    unless current_organization.ip_allowed?(request.remote_ip)
      render json: { error: "IP not allowed" }, status: :forbidden
    end
  end

  # ── Response helpers ────────────────────────────────────────
  def success(data, status: :ok, meta: {})
    render json: { data: data, meta: meta }, status: status
  end

  def error(message, status: :unprocessable_entity, code: nil)
    render json: { error: message, code: code }, status: status
  end

  def paginate(collection)
    pagy, records = pagy(collection)
    success(records, meta: { page: pagy.page, per_page: pagy.items, total: pagy.count })
  end

  # ── Error handlers ──────────────────────────────────────────
  def not_found(exception)
    error(exception.message, status: :not_found)
  end

  def unprocessable_entity(exception)
    error(exception.record.errors.full_messages.to_sentence, status: :unprocessable_entity)
  end

  def bad_request(exception)
    error(exception.message, status: :bad_request)
  end

  def too_many_requests(exception)
    error(exception.message, status: :too_many_requests)
  end
end
