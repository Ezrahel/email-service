RSpec.describe Providers::Security::CredentialStore do
  let(:credentials) { { "api_key" => "sk_test_12345", "region" => "us-east-1" } }

  describe ".encrypt" do
    it "encrypts credentials" do
      encrypted = described_class.encrypt(credentials)
      expect(encrypted).not_to include("sk_test")
      expect(encrypted).not_to eq(credentials.to_json)
    end
  end

  describe ".decrypt" do
    it "decrypts encrypted credentials" do
      encrypted = described_class.encrypt(credentials)
      decrypted = described_class.decrypt(encrypted)
      expect(decrypted).to eq(credentials)
    end

    it "returns nil for invalid data" do
      expect(described_class.decrypt("invalid")).to be_nil
    end
  end

  describe ".validate_format!" do
    it "passes for valid credentials" do
      expect { described_class.validate_format!(credentials) }.not_to raise_error
    end

    it "raises for non-hash" do
      expect { described_class.validate_format!("string") }.to raise_error(ArgumentError)
    end

    it "raises for empty hash" do
      expect { described_class.validate_format!({}) }.to raise_error(ArgumentError)
    end
  end
end
