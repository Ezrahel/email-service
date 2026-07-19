FactoryBot.define do
  factory :api_key do
    organization
    user
    name { "Test Key" }
    key_prefix { "em_test_" }
    key_digest { Digest::SHA256.hexdigest("em_test_#{SecureRandom.hex(16)}") }
    key_last_chars { "test" }
    status { "active" }
    scopes { %w[email:send email:read template:manage webhook:manage api_key:manage analytics:read] }
  end
end
