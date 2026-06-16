Email::Engine.routes.draw do
  namespace :v1 do
    # Single email
    post "emails", to: "emails#create"
    get "emails/:id", to: "emails#show"
    delete "emails/:id", to: "emails#cancel"

    # Batch send
    post "batch", to: "batches#create"
    get "batch/:id", to: "batches#show"

    # Templates
    resources :templates, only: %i[index create show update destroy] do
      post "render", to: "templates#render_preview"
      post "send", to: "templates#send_template"
      member do
        post "versions", to: "templates#create_version"
        get "versions", to: "templates#versions"
      end
    end

    # Tracking (open/click pixels)
    get "track/open/:message_id", to: "tracking#open", as: :track_open
    get "track/click/:message_id", to: "tracking#click", as: :track_click

    # Bounce/complaint webhooks (from providers)
    post "bounce", to: "bounces#create"
    post "complaint", to: "bounces#complaint"

    # Scheduled emails
    resources :scheduled_emails, only: %i[index show destroy], controller: "scheduled"
  end
end
