RSpec.describe EventPublisher do
  let(:organization) { create(:organization) }

  describe ".publish" do
    before do
      allow(REDIS_STREAMS).to receive(:xadd)
      allow(EventRecorder).to receive(:record)
      allow(WebhookDispatcher).to receive(:dispatch_async)
    end

    it "publishes to the Redis stream" do
      expect(REDIS_STREAMS).to receive(:xadd).with(
        "events:delivery",
        hash_including(event_type: "email.delivered", organization_id: organization.id),
        maxlen: 100_000
      )

      described_class.publish(
        event_type: "email.delivered",
        organization_id: organization.id,
        payload: { email_id: SecureRandom.uuid }
      )
    end

    it "records the event via EventRecorder" do
      expect(EventRecorder).to receive(:record).with(
        hash_including(event_type: "email.delivered", organization_id: organization.id)
      )

      described_class.publish(
        event_type: "email.delivered",
        organization_id: organization.id,
        payload: {}
      )
    end

    it "dispatches webhooks asynchronously" do
      expect(WebhookDispatcher).to receive(:dispatch_async).with(
        hash_including(event_type: "email.delivered", organization_id: organization.id)
      )

      described_class.publish(
        event_type: "email.delivered",
        organization_id: organization.id,
        payload: {}
      )
    end

    it "returns true on success" do
      result = described_class.publish(
        event_type: "email.delivered",
        organization_id: organization.id,
        payload: {}
      )

      expect(result).to be true
    end

    context "when Redis fails" do
      before do
        allow(REDIS_STREAMS).to receive(:xadd).and_raise(Redis::CommandError.new("NOSCRIPT"))
      end

      it "falls back to direct recording" do
        expect(EventRecorder).to receive(:record)

        described_class.publish(
          event_type: "email.delivered",
          organization_id: organization.id,
          payload: {}
        )
      end

      it "returns false" do
        result = described_class.publish(
          event_type: "email.delivered",
          organization_id: organization.id,
          payload: {}
        )

        expect(result).to be false
      end
    end
  end
end
