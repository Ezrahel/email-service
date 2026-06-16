RSpec.describe Providers::Adapters::SendgridAdapter do
  include_examples "provider adapter contract"

  let(:organization) { create(:organization) }
  let(:provider_config) { create(:provider_config, organization: organization, provider_type: "sendgrid", credentials: { "api_key" => "SG.test" }) }
  let(:email_message) { create(:email_message, organization: organization) }
  let(:adapter) { described_class.new(provider_config) }
  let(:transport_response) do
    Providers::TransportResponse.new(
      status_code: 202,
      body: '{"message_id": "sg-msg-001"}',
      headers: { "x-message-id" => ["sg-msg-001"] },
      duration_ms: 300
    )
  end

  before do
    allow_any_instance_of(Providers::Transport::SendgridTransport).to receive(:post).and_return(transport_response)
  end

  describe "#send_email" do
    it "returns a delivered response" do
      response = adapter.send_email(email_message)
      expect(response).to be_success
    end
  end

  describe "#health_check" do
    let(:health_response) do
      Providers::TransportResponse.new(status_code: 200, body: '{"scopes": ["mail.send"]}', duration_ms: 100)
    end

    before do
      allow_any_instance_of(Providers::Transport::SendgridTransport).to receive(:get).and_return(health_response)
    end

    it "returns healthy" do
      result = adapter.health_check
      expect(result[:healthy]).to be true
    end
  end
end
