RSpec.describe Providers::AdapterRegistry do
  before do
    described_class.register("test_provider", double("TestAdapter"))
  end

  after do
    described_class.instance_variable_get(:@adapters).delete("test_provider")
  end

  describe ".register" do
    it "registers an adapter class" do
      expect(described_class.registered?("test_provider")).to be true
    end
  end

  describe ".get" do
    it "returns the registered adapter" do
      expect(described_class.get("test_provider")).not_to be_nil
    end

    it "raises for unregistered providers" do
      expect { described_class.get("unknown") }.to raise_error(Providers::Errors::ConfigurationError)
    end
  end

  describe ".registered?" do
    it "returns true for registered types" do
      expect(described_class.registered?("test_provider")).to be true
    end

    it "returns false for unknown types" do
      expect(described_class.registered?("nonexistent")).to be false
    end
  end

  describe ".registered_types" do
    it "includes registered types" do
      expect(described_class.registered_types).to include("test_provider")
    end
  end
end
