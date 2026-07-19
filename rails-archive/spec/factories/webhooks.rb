FactoryBot.define do
  factory :webhook do
    organization
    name { Faker::App.name }
    url { Faker::Internet.url }
    events { %w[email.sent email.delivered email.failed] }
    secret { SecureRandom.hex(32) }
    status { "active" }
    is_active { true }
  end
end
