RSpec.describe Providers::Costs::UsageMeter do
  let(:organization) { create(:organization) }

  describe ".record_send" do
    it "creates a usage record" do
      expect {
        described_class.record_send(
          organization_id: organization.id,
          provider_type: "ses",
          quantity: 1
        )
      }.to change(UsageRecord, :count).by(1)
    end
  end

  describe ".monthly_count" do
    before do
      create(:usage_record, organization_id: organization.id, record_type: "email_send", quantity: 10)
      create(:usage_record, organization_id: organization.id, record_type: "email_send", quantity: 5)
    end

    it "sums monthly usage" do
      expect(described_class.monthly_count(organization.id)).to eq(15)
    end
  end

  describe ".daily_count" do
    before do
      create(:usage_record, organization_id: organization.id, record_type: "email_send", quantity: 3)
    end

    it "sums daily usage" do
      expect(described_class.daily_count(organization.id)).to eq(3)
    end
  end
end
