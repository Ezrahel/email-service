RSpec.describe Providers::Routing::Router do
  let(:organization) { create(:organization) }
  let(:domain) { nil }

  describe "#select" do
    context "with no providers" do
      it "returns nil" do
        router = described_class.new(organization: organization)
        expect(router.select).to be_nil
      end
    end

    context "priority mode" do
      let!(:ses) { create(:provider_config, organization: organization, provider_type: "ses", priority: 1, weight: 100) }
      let!(:sendgrid) { create(:provider_config, organization: organization, provider_type: "sendgrid", priority: 2, weight: 100) }

      it "selects from highest priority" do
        router = described_class.new(organization: organization, mode: "priority")
        result = router.select
        expect(result.provider_type).to eq("ses")
      end
    end

    context "weighted mode" do
      let!(:ses) { create(:provider_config, organization: organization, provider_type: "ses", priority: 1, weight: 80) }
      let!(:sendgrid) { create(:provider_config, organization: organization, provider_type: "sendgrid", priority: 1, weight: 20) }

      it "returns a selection" do
        router = described_class.new(organization: organization, mode: "weighted")
        result = router.select
        expect(result).to be_a(Providers::Routing::Router::Selection)
      end
    end

    context "cost_optimized mode" do
      let!(:smtp) { create(:provider_config, organization: organization, provider_type: "smtp", priority: 2) }
      let!(:ses) { create(:provider_config, organization: organization, provider_type: "ses", priority: 1) }

      it "selects cheapest provider" do
        router = described_class.new(organization: organization, mode: "cost_optimized")
        result = router.select
        expect(result.provider_type).to eq("smtp")
      end
    end

    context "failover_only mode" do
      let!(:ses) { create(:provider_config, organization: organization, provider_type: "ses", priority: 1) }
      let!(:sendgrid) { create(:provider_config, organization: organization, provider_type: "sendgrid", priority: 2) }

      it "selects highest priority" do
        router = described_class.new(organization: organization, mode: "failover_only")
        result = router.select
        expect(result.provider_type).to eq("ses")
      end
    end
  end

  describe "#select_failover" do
    let!(:ses) { create(:provider_config, organization: organization, provider_type: "ses", priority: 1) }
    let!(:sendgrid) { create(:provider_config, organization: organization, provider_type: "sendgrid", priority: 2) }

    it "selects a different provider" do
      router = described_class.new(organization: organization)
      result = router.select_failover("ses")
      expect(result.provider_type).to eq("sendgrid")
    end

    it "returns nil when no alternative" do
      router = described_class.new(organization: organization)
      result = router.select_failover("sendgrid")
      expect(result).to be_nil
    end
  end
end
