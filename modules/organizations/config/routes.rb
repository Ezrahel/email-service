Organizations::Engine.routes.draw do
  namespace :v1 do
    resources :organizations, only: %i[index show create update destroy] do
      resources :users, only: %i[index create destroy], module: :organizations
      resources :teams, only: %i[index create update destroy], module: :organizations
      resources :projects, only: %i[index create show update destroy], module: :organizations
      resources :invitations, only: %i[index create], module: :organizations
    end

    resources :users, only: %i[index show update] do
      post "invite", to: "users#invite"
      post "accept_invite", to: "users#accept_invite"
    end

    resources :projects, only: %i[show update destroy] do
      get "usage", to: "projects#usage"
    end
  end
end
