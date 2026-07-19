RSpec.describe CircuitChecker do
  let(:org_id) { SecureRandom.uuid }

  before do
    REDIS_POOL.with { |conn| conn.flushdb }
  end

  describe ".open?" do
    it "returns false when under threshold" do
      expect(described_class.open?("ses", org_id)).to be false
    end

    it "returns true after threshold exceeded" do
      6.times { described_class.record_failure("ses", org_id) }
      expect(described_class.open?("ses", org_id)).to be true
    end
  end

  describe ".record_failure" do
    it "counts failures in Redis" do
      key = "circuit:ses:#{org_id}"
      described_class.record_failure("ses", org_id)
      count = REDIS_POOL.with { |conn| conn.get(key).to_i }
      expect(count).to eq(1)
    end
  end

  describe ".record_success" do
    it "resets the circuit" do
      6.times { described_class.record_failure("ses", org_id) }
      described_class.record_success("ses", org_id)
      expect(described_class.open?("ses", org_id)).to be false
    end
  end

  describe ".reset!" do
    it "clears all circuit keys" do
      described_class.record_failure("ses", org_id)
      described_class.reset!("ses", org_id)

      expect(described_class.open?("ses", org_id)).to be false
    end
  end
end
