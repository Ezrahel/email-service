RSpec.describe RetryPolicy do
  describe ".delay_for" do
    it "exponential backoff with jitter" do
      delays = (1..5).map { |i| described_class.delay_for(i) }
      expect(delays[0]).to be_between(10, 15)    # 10s + jitter
      expect(delays[1]).to be_between(20, 25)    # 20s + jitter
      expect(delays[2]).to be_between(40, 45)    # 40s + jitter
      expect(delays[3]).to be_between(80, 85)    # 80s + jitter
      expect(delays[4]).to be_between(160, 165)  # 160s + jitter
    end

    it "caps at MAX_DELAY" do
      delay = described_class.delay_for(15)
      expect(delay).to be <= 24.hours
    end

    it "returns 0 for attempt 0" do
      expect(described_class.delay_for(0)).to eq(0)
    end
  end

  describe ".retryable?" do
    it "returns true for attempts under max" do
      expect(described_class.retryable?(0)).to be true
      expect(described_class.retryable?(4)).to be true
    end

    it "returns false after max attempts" do
      expect(described_class.retryable?(5)).to be false
    end

    it "returns false for non-retryable errors" do
      expect(described_class.retryable?(0, error_class: "Errors::ValidationError")).to be false
      expect(described_class.retryable?(0, error_class: "Errors::AuthError")).to be false
    end
  end

  describe ".should_dead_letter?" do
    it "returns true when retries exhausted" do
      expect(described_class.should_dead_letter?(5)).to be true
    end

    it "returns true for non-retryable errors" do
      expect(described_class.should_dead_letter?(0, error_class: "Errors::ValidationError")).to be true
    end
  end
end
