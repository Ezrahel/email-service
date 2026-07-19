RSpec.describe Providers::Costs::QuotaEnforcer do
  let(:organization) { create(:organization, plan: "free", monthly_email_quota: 100) }

  describe ".check_send" do
    context "under quota" do
      it "allows the send" do
        result = described_class.check_send(organization)
        expect(result.allowed?).to be true
      end
    end

    context "over quota" do
      before do
        create_list(:usage_record, 101,
          organization_id: organization.id,
          record_type: "email_send",
          record_date: Date.current,
          quantity: 1
        )
      end

      it "denies the send" do
        result = described_class.check_send(organization)
        expect(result.allowed?).to be false
        expect(result.reason).to include("quota exceeded")
      end
    end
  end

  describe ".check_rate_limit" do
    before { REDIS_POOL.with { |conn| conn.flushdb } }

    it "allows under rate limit" do
      result = described_class.check_rate_limit(organization)
      expect(result.allowed?).to be true
    end
  end

  describe ".check_all" do
    it "returns all quota results" do
      result = described_class.check_all(organization)
      expect(result.allowed?).to be true
    end
  end
end
