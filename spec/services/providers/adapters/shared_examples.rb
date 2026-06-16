RSpec.shared_examples "provider adapter contract" do
  describe "required methods" do
    it { is_expected.to respond_to(:send_email) }
    it { is_expected.to respond_to(:send_batch) }
    it { is_expected.to respond_to(:cancel_delivery) }
    it { is_expected.to respond_to(:check_status) }
    it { is_expected.to respond_to(:health_check) }
    it { is_expected.to respond_to(:validate_domain) }
    it { is_expected.to respond_to(:estimate_cost) }
  end

  describe "provider metadata" do
    let(:metadata) { adapter.provider_metadata }

    it "includes type" do
      expect(metadata[:type]).to be_present
    end

    it "includes max_retries" do
      expect(metadata[:max_retries]).to be_positive
    end

    it "includes timeout_ms" do
      expect(metadata[:timeout_ms]).to be_positive
    end
  end
end
