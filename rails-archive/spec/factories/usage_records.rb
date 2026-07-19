FactoryBot.define do
  factory :usage_record do
    organization
    metric { "emails_sent" }
    granularity { "daily" }
    bucket { Time.current.beginning_of_day }
    count { 100 }
    billable_count { 100 }
    cost { 0.10 }
    metadata { {} }
  end
end
