RSpec.describe EventRecorder do
  describe ".record" do
    let(:organization) { create(:organization) }

    it "creates an event log entry" do
      expect {
        described_class.record(
          event_type: "email.delivered",
          organization_id: organization.id,
          payload: { email_id: SecureRandom.uuid }
        )
      }.to change(EventLog, :count).by(1)
    end

    it "sets the correct event type" do
      described_class.record(
        event_type: "email.delivered",
        organization_id: organization.id,
        payload: {}
      )

      expect(EventLog.last.event_type).to eq("email.delivered")
    end

    it "sets the source to email_service" do
      described_class.record(
        event_type: "email.delivered",
        organization_id: organization.id,
        payload: {}
      )

      expect(EventLog.last.source).to eq("email_service")
    end
  end

  describe ".record_delivery_event" do
    let(:organization) { create(:organization) }
    let(:email_message) { create(:email_message, organization: organization) }
    let(:delivery) { create(:delivery, email_message: email_message, organization: organization) }

    it "creates a delivery event" do
      expect {
        described_class.record_delivery_event(
          delivery: delivery,
          event_type: "opened",
          metadata: { user_agent: "Test Agent" }
        )
      }.to change(DeliveryEvent, :count).by(1)
    end
  end
end
