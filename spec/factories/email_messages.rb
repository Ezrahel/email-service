FactoryBot.define do
  factory :email_message do
    organization
    association :domain
    batch_id { SecureRandom.uuid }
    from_address { "sender@#{domain&.domain || 'example.com'}" }
    to_address { Faker::Internet.email }
    subject { Faker::Lorem.sentence }
    html_body { "<h1>#{Faker::Lorem.sentence}</h1>" }
    text_body { Faker::Lorem.paragraph }
    status { "queued" }
    headers { {} }
    tags { [] }
  end
end
