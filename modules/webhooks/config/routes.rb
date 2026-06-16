Webhooks::Engine.routes.draw do
  namespace :v1 do
    resources :webhook_endpoints, only: %i[index create show update destroy] do
      post "test", to: "webhook_endpoints#test"
      get "deliveries", to: "webhook_endpoints#deliveries"
    end

    resources :webhook_deliveries, only: %i[index show] do
      post "retry", to: "webhook_deliveries#retry"
    end

    # Event logs
    get "events", to: "events#index"
    get "events/:id", to: "events#show"
  end
end
