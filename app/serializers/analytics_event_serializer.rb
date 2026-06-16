class AnalyticsEventSerializer < ApplicationSerializer
  attributes :id, :event_type, :event_timestamp, :ip_address, :user_agent,
             :metadata, :provider, :created_at
end
