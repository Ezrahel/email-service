require "rails_helper"

RSpec.describe Notifications::SlackNotifier, type: :service do
  let(:organization) { create(:organization) }
  let(:alert) { { type: :test_alert, severity: :warning, message: "Test alert", value: 42, threshold: 10 } }

  describe "#call" do
    before do
      stub_const("ENV", ENV.to_h.merge("SLACK_WEBHOOK_URL" => "https://hooks.slack.com/test"))
    end

    it "sends HTTP request to slack webhook" do
      stub = stub_request(:post, "https://hooks.slack.com/test")
        .to_return(status: 200, body: "ok")

      described_class.call(alert: alert, organization: organization)
      expect(stub).to have_been_requested
    end

    context "when no webhook URL is set" do
      before do
        stub_const("ENV", ENV.to_h.merge("SLACK_WEBHOOK_URL" => nil))
      end

      it "does not send a request" do
        expect(HTTParty).not_to receive(:post)
        described_class.call(alert: alert, organization: organization)
      end
    end
  end
end
