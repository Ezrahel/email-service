Rails.application.routes.draw do
  # ── Health (no auth) ──────────────────────────────────────────
  get "/health", to: "health#show"
  get "/health/readiness", to: "health#readiness"
  get "/health/liveness", to: "health#liveness"

  # ── API v1 ────────────────────────────────────────────────────
  namespace :api do
    namespace :v1 do
      # Authentication
      post "auth/login",  to: "auth#login"
      post "auth/refresh", to: "auth#refresh"
      delete "auth/logout", to: "auth#logout"

      # Emails
      resources :emails, only: %i[create show index]
      post "emails/batch",    to: "emails#batch"
      post "emails/validate", to: "emails#validate"

      # Domains
      resources :domains, only: %i[index create show destroy] do
        post :verify, on: :member
      end

      # Templates
      resources :templates, only: %i[index create show update destroy] do
        member do
          post :send
        end
        resources :versions, only: %i[index show create],
                  controller: "template_versions"
      end

      # Webhooks
      resources :webhooks, only: %i[index create show update destroy] do
        post :test, on: :member
      end

      # Analytics
      get "analytics",            to: "analytics#overview"
      get "analytics/deliverability", to: "analytics#deliverability"
      get "analytics/events",     to: "analytics#events"

      # Dashboard
      get "dashboard/overview",       to: "dashboard#overview"
      get "dashboard/deliverability", to: "dashboard#deliverability"
      get "dashboard/usage",          to: "dashboard#usage"
      get "dashboard/providers",      to: "dashboard#providers"
      get "dashboard/activity",       to: "dashboard#activity"
      get "dashboard/alerts",         to: "dashboard#alerts"

      # API Keys
      resources :api_keys, only: %i[index create show destroy] do
        post :revoke, on: :member
      end

      # Organizations
      resource :organization, only: %i[show update]
    end
  end
end
