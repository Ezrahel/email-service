Auth::Engine.routes.draw do
  namespace :v1 do
    # Authentication
    post "auth/login", to: "sessions#create"
    post "auth/refresh", to: "sessions#refresh"
    delete "auth/logout", to: "sessions#destroy"

    # API Keys
    resources :api_keys, only: %i[index create show destroy]
    post "api_keys/:id/revoke", to: "api_keys#revoke"

    # IP Allowlists
    resources :ip_allowlists, only: %i[index create destroy]
  end
end
