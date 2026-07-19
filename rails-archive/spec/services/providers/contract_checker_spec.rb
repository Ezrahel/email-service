RSpec.describe Providers::ContractChecker do
  let(:valid_adapter) do
    Class.new do
      def send_email(*) end
      def send_batch(*) end
      def cancel_delivery(*) end
      def check_status(*) end
      def health_check(*) end
      def validate_domain(*) end
      def estimate_cost(*) end
    end
  end

  let(:invalid_adapter) do
    Class.new do
      def send_email(*) end
    end
  end

  describe ".verify!" do
    it "passes for adapters with all required methods" do
      expect(described_class.verify!(valid_adapter)).to be true
    end

    it "raises for adapters missing methods" do
      expect { described_class.verify!(invalid_adapter) }
        .to raise_error(Providers::Errors::ConfigurationError, /missing required methods/)
    end
  end

  describe ".contract_summary" do
    it "returns a hash of method presence" do
      summary = described_class.contract_summary(valid_adapter)
      expect(summary[:send_email]).to be true
      expect(summary[:estimate_cost]).to be true
    end
  end
end
