Rails.application.config.middleware.insert_before 0, RequestTracing
Rails.application.config.middleware.insert_before Rack::Runtime, Rack::Attack
