Rails.application.routes.draw do
  # Health checks (non-versioned, no auth)
  get "/health", to: "health#show"
  get "/health/readiness", to: "health#readiness"
  get "/health/liveness", to: "health#liveness"

  # Mount modular engines
  mount Auth::Engine, at: "/"
  mount Organizations::Engine, at: "/"
  mount Email::Engine, at: "/"
  mount Providers::Engine, at: "/"
  mount Webhooks::Engine, at: "/"
  mount Analytics::Engine, at: "/"
  mount Billing::Engine, at: "/"

  # API documentation
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"
end
