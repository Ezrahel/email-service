RSpec.describe ProviderRouter do
  let(:organization) { create(:organization) }

  describe ".select_provider" do
    context "with no provider configs" do
      it "returns nil" do
        expect(described_class.select_provider(organization: organization)).to be_nil
      end
    end

    context "with a single active provider" do
      let!(:config) { create(:provider_config, organization: organization, provider_type: "ses", priority: 1, weight: 100) }

      it "returns that provider" do
        result = described_class.select_provider(organization: organization)
        expect(result).to be_a(ProviderRouter::ProviderSelection)
        expect(result.provider_type).to eq("ses")
        expect(result.provider_config).to eq(config)
      end
    end

    context "with multiple priority levels" do
      let!(:primary) { create(:provider_config, organization: organization, provider_type: "ses", priority: 1, weight: 100) }
      let!(:secondary) { create(:provider_config, organization: organization, provider_type: "sendgrid", priority: 2, weight: 100) }

      it "selects from the highest priority group" do
        result = described_class.select_provider(organization: organization)
        expect(result.provider_type).to eq("ses")
      end
    end

    context "with weighted selection" do
      let!(:ses) { create(:provider_config, organization: organization, provider_type: "ses", priority: 1, weight: 80) }
      let!(:sendgrid) { create(:provider_config, organization: organization, provider_type: "sendgrid", priority: 1, weight: 20) }

      it "returns a ProviderSelection" do
        result = described_class.select_provider(organization: organization)
        expect(result).to be_a(ProviderRouter::ProviderSelection)
      end
    end

    context "with unhealthy providers" do
      let!(:healthy) { create(:provider_config, organization: organization, provider_type: "ses", priority: 1, health_score: 90) }
      let!(:unhealthy) { create(:provider_config, organization: organization, provider_type: "sendgrid", priority: 1, health_score: 30) }

      it "only considers healthy providers" do
        result = described_class.select_provider(organization: organization)
        expect(result.provider_type).to eq("ses")
      end
    end
  end

  describe ".select_failover" do
    let!(:ses) { create(:provider_config, organization: organization, provider_type: "ses", priority: 1) }
    let!(:sendgrid) { create(:provider_config, organization: organization, provider_type: "sendgrid", priority: 2) }

    it "selects a different provider" do
      result = described_class.select_failover(organization: organization, failed_provider: "ses")
      expect(result.provider_type).to eq("sendgrid")
    end

    it "returns nil when no failover available" do
      result = described_class.select_failover(organization: organization, failed_provider: "sendgrid")
      expect(result).to be_nil
    end
  end
end
