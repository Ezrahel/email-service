FactoryBot.define do
  factory :role do
    name { "Developer" }
    slug { "developer" }
    system { true }
    permissions { { send_emails: true, read_analytics: true } }
  end
end
