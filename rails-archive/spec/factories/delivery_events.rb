FactoryBot.define do
  factory :delivery_event do
    delivery
    email_message
    organization
    event_type { "delivered" }
    provider { "ses" }
    event_timestamp { Time.current }
    metadata { {} }
  end
end
