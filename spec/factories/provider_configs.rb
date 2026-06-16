FactoryBot.define do
  factory :provider_config do
    organization
    name { Faker::Company.name }
    provider_type { "ses" }
    credentials { { access_key_id: "AKIA_TEST", secret_access_key: "test_secret", region: "us-east-1" } }
    weight { 50 }
    priority { 1 }
    is_active { true }
    is_primary { false }
    status { "active" }
    health_score { 100.0 }
    settings { { endpoint: "https://email.us-east-1.amazonaws.com" } }
  end
end
