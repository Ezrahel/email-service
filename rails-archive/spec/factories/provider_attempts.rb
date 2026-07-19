FactoryBot.define do
  factory :provider_attempt do
    delivery
    organization
    attempt_number { 1 }
    provider { "ses" }
    status { "success" }
    duration_ms { rand(50..500) }
    ip_address { Faker::Internet.ip_v4_address }
  end
end
