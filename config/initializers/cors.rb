Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "*"
    resource "*",
      headers: :any,
      methods: %i[get post put patch delete options head],
      expose: %w[X-Request-Id X-RateLimit-Limit X-RateLimit-Remaining X-RateLimit-Reset]
  end
end
