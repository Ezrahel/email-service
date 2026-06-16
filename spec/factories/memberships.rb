FactoryBot.define do
  factory :membership do
    organization
    user
    role
    status { "active" }
  end
end
