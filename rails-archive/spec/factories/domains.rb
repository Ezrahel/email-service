FactoryBot.define do
  factory :domain do
    organization
    domain { Faker::Internet.unique.domain_name }
    status { "verified" }
    is_verified { true }
    verified_at { Time.current }
    verification_token { SecureRandom.hex(16) }
    dkim_selector { "mailo" }
    spf_record { "v=spf1 include:mail.#{domain} ~all" }
    dkim_record { "v=DKIM1; k=rsa; p=placeholder" }
    dmarc_record { "v=DMARC1; p=none" }
    mx_record { "10 mail.#{domain}" }
  end
end
