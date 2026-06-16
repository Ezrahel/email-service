FactoryBot.define do
  factory :webhook_delivery do
    webhook
    organization
    event_type { "email.delivered" }
    event_id { SecureRandom.uuid }
    attempt { 1 }
    status { "pending" }
  end
end
