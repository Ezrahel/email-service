module ErrorHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :handle_validation_error
    rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing
    rescue_from Errors::ApplicationError, with: :handle_api_error
  end

  private

  def handle_api_error(exception)
    render json: exception.to_h, status: exception.status
  end

  def handle_not_found(exception)
    error = Errors::NotFoundError.new(exception.message)
    render json: error.to_h, status: :not_found
  end

  def handle_validation_error(exception)
    details = exception.record.errors.messages.transform_values(&:join)
    error = Errors::ValidationError.new(details: details)
    render json: error.to_h, status: :unprocessable_entity
  end

  def handle_parameter_missing(exception)
    error = Errors::ValidationError.new("Missing parameter: #{exception.param}")
    render json: error.to_h, status: :unprocessable_entity
  end

  def render_error(code:, message:, status:, details: {})
    error = Errors::ApplicationError.new(message, code: code, status: Rack::Utils.status_code(status), details: details)
    render json: error.to_h, status: status
  end

  def render_success(data, status: :ok, meta: {})
    result = { data: data }
    result[:meta] = meta if meta.present?
    render json: result, status: status
  end

  def render_collection(records, serializer, meta: {})
    pagination = pagination_meta(records) if records.respond_to?(:total_count)
    render_success(
      serializer.new(records).serializable_hash[:data],
      meta: meta.merge(pagination || {})
    )
  end

  def pagination_meta(collection)
    {
      page: collection.current_page,
      per_page: collection.limit_value,
      total: collection.total_count,
      pages: collection.total_pages
    }
  end
end
