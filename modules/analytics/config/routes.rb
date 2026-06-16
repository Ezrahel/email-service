Analytics::Engine.routes.draw do
  namespace :v1 do
    # Dashboard aggregates
    get "analytics/overview", to: "dashboard#overview"
    get "analytics/delivery", to: "dashboard#delivery"
    get "analytics/engagement", to: "dashboard#engagement"
    get "analytics/timeseries", to: "dashboard#timeseries"

    # Raw event log access
    get "analytics/events", to: "events#index"

    # Export
    post "analytics/export", to: "exports#create"
    get "analytics/exports/:id", to: "exports#show"
  end
end
