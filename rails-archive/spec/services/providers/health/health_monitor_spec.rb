RSpec.describe Providers::Health::HealthMonitor do
  let(:organization) { create(:organization) }
  let(:provider_config) { create(:provider_config, organization: organization, health_score: 90) }

  describe ".check" do
    context "when provider is healthy" do
      before do
        allow_any_instance_of(Providers::ProviderAdapter).to receive(:health_check).and_return({ healthy: true })
      end

      it "returns a healthy result" do
        result = described_class.check(provider_config)
        expect(result.healthy?).to be true
      end

      it "updates health score positively" do
        expect { described_class.check(provider_config) }
          .to change { provider_config.reload.health_score }.by_at_most(100)
      end
    end

    context "when provider is unhealthy" do
      before do
        allow_any_instance_of(Providers::ProviderAdapter).to receive(:health_check).and_return({ healthy: false, error: "Connection refused" })
      end

      it "returns an unhealthy result" do
        result = described_class.check(provider_config)
        expect(result.healthy?).to be false
      end
    end

    context "when health check raises" do
      before do
        allow_any_instance_of(Providers::ProviderAdapter).to receive(:health_check).and_raise(StandardError.new("Unexpected"))
      end

      it "returns unhealthy" do
        result = described_class.check(provider_config)
        expect(result.healthy?).to be false
        expect(result.error).to eq("Unexpected")
      end
    end

    context "with recent check cached" do
      before do
        provider_config.update!(last_health_check_at: 10.seconds.ago, health_score: 95)
        allow_any_instance_of(Providers::ProviderAdapter).not_to receive(:health_check)
      end

      it "returns cached result" do
        result = described_class.check(provider_config)
        expect(result.health_score).to eq(95)
      end
    end
  end

  describe ".status_label" do
    it "returns healthy for high scores" do
      expect(described_class.status_label(85)).to eq("healthy")
    end

    it "returns degraded for mid scores" do
      expect(described_class.status_label(50)).to eq("degraded")
    end

    it "returns failed for low scores" do
      expect(described_class.status_label(10)).to eq("failed")
    end
  end
end
