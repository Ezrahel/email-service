RSpec.describe WebhookSigner do
  let(:payload) { { event: "email.delivered", id: "abc-123" } }
  let(:secret) { "test_secret_key_12345" }

  describe ".sign" do
    it "returns a versioned signature" do
      signature = described_class.sign(payload, secret)
      expect(signature).to start_with("v1=")
      expect(signature.length).to be > 10
    end
  end

  describe ".verify" do
    it "verifies a valid signature" do
      signature = described_class.sign(payload, secret)
      expect(described_class.verify(payload, signature, secret)).to be true
    end

    it "rejects an invalid signature" do
      expect(described_class.verify(payload, "v1=invalid", secret)).to be false
    end

    it "rejects a signature with wrong secret" do
      signature = described_class.sign(payload, secret)
      expect(described_class.verify(payload, signature, "wrong_secret")).to be false
    end
  end

  describe ".verify_with_timestamp" do
    it "verifies a valid timestamped signature" do
      signature = described_class.sign(payload, secret)
      expect(described_class.verify_with_timestamp(payload, signature, secret, max_age: 1.hour)).to be true
    end

    it "rejects an expired signature" do
      signature = described_class.sign(payload, secret)
      Timecop.travel(10.minutes.from_now) do
        expect(described_class.verify_with_timestamp(payload, signature, secret, max_age: 5.minutes)).to be false
      end
    end

    it "returns false for empty signature" do
      expect(described_class.verify_with_timestamp(payload, "", secret)).to be false
    end
  end
end
