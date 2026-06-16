RSpec.describe Providers::Webhooks::WebhookProcessor do
  let(:organization) { create(:organization) }
  let(:email_message) { create(:email_message, organization: organization) }
  let(:delivery) { create(:delivery, email_message: email_message, organization: organization, provider_message_id: "ext-msg-001") }

  describe "#process" do
    context "with SES delivery event" do
      let(:request) do
        double(
          "Request",
          headers: {
            "X-SES-Signature" => "sig",
            "X-SES-Certificate-Url" => "https://cert.example.com"
          },
          body: double(read: JSON.dump({
            "Message" => JSON.dump({
              "notificationType" => "Delivery",
              "mail" => { "messageId" => "ext-msg-001" },
              "delivery" => { "timestamp" => "2025-01-01T00:00:00Z" }
            })
          }))
        )
      end
      let(:validator) { instance_double(Providers::Webhooks::WebhookValidator) }
      let(:processor) { described_class.new(provider_type: "ses") }

      before do
        allow(Providers::Webhooks::WebhookValidator).to receive(:new).and_return(validator)
        allow(validator).to receive(:validate).and_return(
          Providers::Webhooks::WebhookValidator::ValidationResult.new(
            valid: true, event_type: "delivered", provider: "ses",
            payload: {
              "notificationType" => "Delivery",
              "mail" => { "messageId" => "ext-msg-001" }
            }
          )
        )
        delivery
      end

      it "processes the delivery" do
        result = processor.process(request)
        expect(result.valid?).to be true
        expect(delivery.reload.status).to eq("delivered")
      end
    end
  end
end
