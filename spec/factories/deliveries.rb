FactoryBot.define do
  factory :delivery do
    email_message
    organization
    provider_config
    status { "pending" }
    provider { "ses" }
    attempt_count { 0 }
    max_attempts { 3 }
    open_count { 0 }
    click_count { 0 }
  end
end
