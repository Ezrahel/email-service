Billing::Engine.routes.draw do
  namespace :v1 do
    resources :plans, only: %i[index show]

    resources :subscriptions, only: %i[index show create update] do
      post "cancel", to: "subscriptions#cancel"
      post "reactivate", to: "subscriptions#reactivate"
    end

    get "billing/usage", to: "usage#current"
    get "billing/usage/timeseries", to: "usage#timeseries"
    get "billing/invoices", to: "invoices#index"
    get "billing/invoices/:id", to: "invoices#show"
  end
end
