class RequestTracing
  def initialize(app)
    @app = app
  end

  def call(env)
    request_id = env["HTTP_X_REQUEST_ID"] || SecureRandom.uuid
    env["REQUEST_ID"] = request_id

    status, headers, body = @app.call(env)

    headers["X-Request-Id"] = request_id

    [status, headers, body]
  end
end
