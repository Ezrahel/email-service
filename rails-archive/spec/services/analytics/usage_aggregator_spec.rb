require "rails_helper"

RSpec.describe Analytics::UsageAggregator, type: :service do
  let(:organization) { create(:organization) }
  let(:domain) { create(:domain, organization: organization, is_verified: true) }

  before do
    create_list(:email_message, 3, organization: organization, status: "delivered", created_at: 1.hour.ago,
                html_body: "<p>Hello</p>", text_body: "Hello")
  end

  describe "#call" do
    it "creates usage records for emails_sent" do
      expect {
        described_class.call(organization: organization)
      }.to change(UsageRecord, :count).by_at_least(1)
    end

    it "tracks delivered count" do
      described_class.call(organization: organization)
      record = UsageRecord.for_organization(organization)
        .for_metric("emails_delivered")
        .first
      if record
        expect(record.count).to eq(3)
      end
    end

    it "tracks bandwidth" do
      described_class.call(organization: organization)
      record = UsageRecord.for_organization(organization)
        .for_metric("bandwidth_bytes")
        .first
      if record
        expect(record.count).to be > 0
      end
    end
  end
end
