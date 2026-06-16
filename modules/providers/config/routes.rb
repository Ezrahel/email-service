Providers::Engine.routes.draw do
  namespace :v1 do
    # Domain management
    resources :domains, only: %i[index create show destroy] do
      post "verify", to: "domains#verify"
      get "dns-records", to: "domains#dns_records"
    end

    # Provider configuration
    resources :provider_configs, only: %i[index show create update destroy] do
      post "test", to: "provider_configs#test"
    end

    # Provider health
    get "providers/health", to: "providers#health"
    get "providers/stats", to: "providers#stats"
  end
end
