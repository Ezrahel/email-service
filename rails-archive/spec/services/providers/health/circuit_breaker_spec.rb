RSpec.describe Providers::Health::CircuitBreaker do
  let(:organization) { create(:organization) }
  let(:provider_config) { create(:provider_config, organization: organization) }
  let(:cb) { described_class.new(provider_config) }

  before do
    REDIS_POOL.with { |conn| conn.flushdb }
  end

  describe "#allow_request?" do
    it "allows when healthy" do
      expect(cb.allow_request?).to be true
    end

    it "blocks when open" do
      described_class::FAILURE_THRESHOLD.times { cb.record_failure }
      expect(cb.allow_request?).to be false
    end

    it "allows half-open probes" do
      described_class::FAILURE_THRESHOLD.times { cb.record_failure }
      Timecop.travel(described_class::RESET_TIMEOUT.from_now) do
        expect(cb.allow_request?).to be true
      end
    end
  end

  describe "#record_success" do
    it "resets the circuit" do
      described_class::FAILURE_THRESHOLD.times { cb.record_failure }
      cb.record_success
      expect(cb.allow_request?).to be true
    end
  end

  describe "#current_state" do
    it "returns healthy state initially" do
      state = cb.current_state
      expect(state.healthy?).to be true
    end

    it "returns open state after failures" do
      described_class::FAILURE_THRESHOLD.times { cb.record_failure }
      state = cb.current_state
      expect(state.open?).to be true
    end
  end
end
