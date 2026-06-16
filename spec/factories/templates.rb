FactoryBot.define do
  factory :template do
    organization
    name { Faker::Marketing.buzzwords }
    slug { Faker::Internet.unique.slug(words: nil) }
    subject { "Hello {{ name }}" }
    html_body { "<h1>Hello {{ name }}</h1>" }
    text_body { "Hello {{ name }}" }
    variables { [{ "name" => "name", "type" => "string", "required" => true }] }
    is_active { true }
  end
end
