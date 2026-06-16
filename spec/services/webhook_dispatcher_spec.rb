RSpec.describe WebhookDispatcher do
  describe "#deliver!" do
    let(:webhook) { create(:webhook, url: "https://hooks.example.com/callback", secret: "sec_123") }
    let(:webhook_delivery) { create(:webhook_delivery, webhook: webhook, event_type: "email.delivered", request_body: '{"email_id":"abc-123"}') }

    before do
      stub_request(:post, "https://hooks.example.com/callback").to_return(status: 200, body: '{"ok":true}')
    end

    it "sends a POST request to the webhook URL" do
      described_class.new(delivery: webhook_delivery).deliver!

      expect(WebMock).to have_requested(:post, "https://hooks.example.com/callback").once
    end

    it "includes the signature header" do
      described_class.new(delivery: webhook_delivery).deliver!

      expect(WebMock).to have_requested(:post, "https://hooks.example.com/callback")
        .with { |req| req.headers["X-EmailService-Signature"].to_s.start_with?("v1=") }
    end

    it "includes the event type header" do
      described_class.new(delivery: webhook_delivery).deliver!

      expect(WebMock).to have_requested(:post, "https://hooks.example.com/callback")
        .with { |req| req.headers["X-EmailService-Event"] == "email.delivered" }
    end

    it "returns a successful result" do
      result = described_class.new(delivery: webhook_delivery).deliver!
      expect(result.success?).to be true
      expect(result.http_status).to eq(200)
    end

    context "when webhook returns error" do
      before do
        stub_request(:post, "https://hooks.example.com/callback").to_return(status: 500, body: "Server Error")
      end

      it "returns a failure result" do
        result = described_class.new(delivery: webhook_delivery).deliver!
        expect(result.success?).to be false
        expect(result.http_status).to eq(500)
      end
    end

    context "when webhook times out" do
      before do
        stub_request(:post, "https://hooks.example.com/callback").to_timeout
      end

      it "returns a failure result" do
        result = described_class.new(delivery: webhook_delivery).deliver!
        expect(result.success?).to be false
        expect(result.error).to include("Timeout")
      end
    end
  end

  describe ".dispatch_async" do
    let(:organization) { create(:organization) }
    let!(:webhook) { create(:webhook, organization: organization, events: ["email.delivered"]) }

    it "creates webhook deliveries" do
      expect {
        described_class.dispatch_async(
          event_type: "email.delivered",
          organization_id: organization.id,
          payload: { email_id: SecureRandom.uuid }
        )
      }.to change(WebhookDelivery, :count).by(1)
    end

    it "enqueues delivery workers" do
      expect {
        described_class.dispatch_async(
          event_type: "email.delivered",
          organization_id: organization.id,
          payload: {}
        )
      }.to change(WebhookDeliveryWorker.jobs, :size).by(1)
    end

    it "does not dispatch to webhooks that don't subscribe to the event" do
      create(:webhook, organization: organization, events: ["email.bounced"])

      expect {
        described_class.dispatch_async(
          event_type: "email.delivered",
          organization_id: organization.id,
          payload: {}
        )
      }.to change(WebhookDelivery, :count).by(1)
    end
  end
end
