require "rails_helper"

RSpec.describe SendEmailForm, type: :form do
  let(:organization) { create(:organization) }
  let(:domain) { create(:domain, organization: organization, is_verified: true) }

  let(:valid_attributes) do
    {
      from: "sender@#{domain.domain}",
      to: ["recipient@example.com"],
      subject: "Test",
      html: "<h1>Hello</h1>",
      organization: organization
    }
  end

  it "is valid with correct attributes" do
    form = described_class.new(valid_attributes)
    expect(form).to be_valid
  end

  it "requires from" do
    form = described_class.new(valid_attributes.merge(from: nil))
    expect(form).to be_invalid
  end

  it "requires to" do
    form = described_class.new(valid_attributes.merge(to: []))
    expect(form).to be_invalid
  end

  it "requires subject" do
    form = described_class.new(valid_attributes.merge(subject: nil))
    expect(form).to be_invalid
  end

  it "requires html or text" do
    form = described_class.new(valid_attributes.merge(html: nil, text: nil))
    expect(form).to be_invalid
  end

  it "limits to to 50 recipients" do
    form = described_class.new(valid_attributes.merge(to: Array.new(51) { Faker::Internet.email }))
    expect(form).to be_invalid
  end
end
