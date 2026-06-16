class ApplicationController < ActionController::API
  include ActionController::MimeResponds
  include ActionController::RequestForgeryProtection

  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
  rescue_from ActionController::ParameterMissing, with: :bad_request
  rescue_from RateLimitExceeded, with: :too_many_requests

  before_action :authenticate_request
  before_action :set_request_attributes
  before_action :check_ip_allowlist

  # ── Auth Context ────────────────────────────────────────────
  attr_reader :current_user, :current_organization, :current_api_key

  private

  def authenticate_request
    authenticator = Auth::AuthenticateRequest.new(request)
    result = authenticator.call

    if result.success?
      @current_user = result.user
      @current_organization = result.organization
      @current_api_key = result.api_key
    else
      render json: { error: result.error }, status: :unauthorized
    end
  end

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
