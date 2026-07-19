RSpec.describe Providers::ProviderResponse do
  describe ".delivered" do
    subject { described_class.delivered(message_id: "msg-123", duration_ms: 450) }

    it { is_expected.to be_success }
    it { is_expected.not_to be_failed }
    it { is_expected.not_to be_retryable_failure }
    its(:provider_message_id) { is_expected.to eq("msg-123") }
    its(:status) { is_expected.to eq("delivered") }
  end

  describe ".failed" do
    subject { described_class.failed(error_message: "Timeout", retryable: true) }

    it { is_expected.not_to be_success }
    it { is_expected.to be_failed }
    it { is_expected.to be_retryable_failure }
    its(:error_message) { is_expected.to eq("Timeout") }
  end

  describe ".bounced" do
    subject { described_class.bounced(error_message: "Hard bounce") }

    it { is_expected.not_to be_success }
    it { is_expected.to be_failed }
    it { is_expected.not_to be_retryable_failure }
  end

  describe ".rejected" do
    subject { described_class.rejected(error_message: "Invalid recipient") }

    it { is_expected.not_to be_success }
    it { is_expected.to be_failed }
    it { is_expected.not_to be_retryable_failure }
  end
end
