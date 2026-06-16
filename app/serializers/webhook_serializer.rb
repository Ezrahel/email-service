class WebhookSerializer < ApplicationSerializer
  attributes :id, :name, :url, :events, :status, :api_version, :is_active,
             :last_sent_at, :last_success_at, :last_failure_at,
             :created_at, :updated_at
end
