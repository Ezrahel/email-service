require "rails_helper"

RSpec.describe Monitoring::ProviderHealthDashboard, type: :service do
  describe "#call" do
    subject { described_class.call }

    it "returns a hash with timestamp and providers" do
      expect(subject).to have_key(:timestamp)
      expect(subject).to have_key(:providers)
      expect(subject).to have_key(:alerts)
    end

    it "includes summary" do
      expect(subject[:summary]).to have_key(:total_providers)
      expect(subject[:summary]).to have_key(:enabled)
    end

    it "provides per-provider details" do
      expect(subject[:providers]).to be_an(Array)
    end

    context "with a provider config" do
      let(:organization) { create(:organization) }
      let!(:config) { create(:provider_config, organization: organization, provider_type: "ses", is_active: true) }

      it "includes the provider" do
        provider_names = subject[:providers].map { |p| p[:provider] }
        expect(provider_names).to include("ses")
      end

      it "returns circuit breaker state" do
        ses = subject[:providers].find { |p| p[:provider] == "ses" }
        expect(ses).to have_key(:circuit_breaker)
      end
    end
  end
end
