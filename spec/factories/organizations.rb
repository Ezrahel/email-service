FactoryBot.define do
  factory :organization do
    name { Faker::Company.name }
    slug { Faker::Internet.unique.slug(words: nil, glue: "-") }
    plan { "starter" }
    status { "active" }
    monthly_email_quota { 10_000 }
    billing_email { Faker::Internet.email }
  end
end
