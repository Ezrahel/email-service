RSpec.describe Providers::Adapters::SesAdapter do
  include_examples "provider adapter contract"

  let(:organization) { create(:organization) }
  let(:provider_config) { create(:provider_config, organization: organization, provider_type: "ses") }
  let(:email_message) { create(:email_message, organization: organization) }
  let(:adapter) { described_class.new(provider_config) }
  let(:aws_client) { instance_double(Aws::SESV2::Client) }

  before do
    allow(adapter).to receive(:transport).and_return(aws_client)
    allow(aws_client).to receive(:send_email).and_return(
      instance_double(Aws::SESV2::Types::SendEmailResponse, message_id: "aws-msg-001")
    )
  end

  describe "#send_email" do
    it "returns a delivered response" do
      response = adapter.send_email(email_message)
      expect(response).to be_success
      expect(response.provider_message_id).to eq("aws-msg-001")
    end

    it "raises normalized error on rejection" do
      allow(aws_client).to receive(:send_email).and_raise(
        Aws::SESV2::Errors::MessageRejected.new(nil, "Invalid email")
      )

      response = adapter.send_email(email_message)
      expect(response.status).to eq("rejected")
    end
  end

  describe "#health_check" do
    before do
      allow(aws_client).to receive(:send_quota).and_return(double("Quota"))
    end

    it "returns healthy" do
      result = adapter.health_check
      expect(result[:healthy]).to be true
    end
  end

  describe "#supports_batch?" do
    it { expect(adapter.supports_batch?).to be true }
  end

  describe "#supports_cancel?" do
    it { expect(adapter.supports_cancel?).to be true }
  end
end
