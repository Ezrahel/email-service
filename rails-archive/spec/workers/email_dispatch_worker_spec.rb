RSpec.describe EmailDispatchWorker do
  let(:organization) { create(:organization) }
  let(:email_message) { create(:email_message, organization: organization) }
  let(:provider_config) { create(:provider_config, organization: organization) }
  let(:delivery) { create(:delivery, email_message: email_message, organization: organization, provider_config: provider_config) }

  describe "#perform" do
    context "when delivery exists and is retryable" do
      let(:coordinator_result) do
        DeliveryCoordinator::Result.new(
          success?: true,
          provider: "ses",
          provider_message_id: "msg-123",
          duration_ms: 450,
          delivery_status: "delivered"
        )
      end

      before do
        allow_any_instance_of(DeliveryCoordinator).to receive(:dispatch!).and_return(coordinator_result)
      end

      it "calls DeliveryCoordinator" do
        expect_any_instance_of(DeliveryCoordinator).to receive(:dispatch!)
        described_class.new.perform(delivery.id)
      end

      it "logs success without error" do
        expect(Rails.logger).not_to receive(:warn)
        described_class.new.perform(delivery.id)
      end
    end

    context "when delivery does not exist" do
      it "returns without error" do
        expect {
          described_class.new.perform(SecureRandom.uuid)
        }.not_to raise_error
      end
    end

    context "when dispatch fails" do
      let(:failed_result) do
        DeliveryCoordinator::Result.new(
          success?: false,
          provider: "ses",
          error: "All providers failed: timeout",
          delivery_status: "failed"
        )
      end

      before do
        allow_any_instance_of(DeliveryCoordinator).to receive(:dispatch!).and_return(failed_result)
      end

      it "logs a warning" do
        expect(Rails.logger).to receive(:warn).with(hash_including(event: "delivery_failed"))
        described_class.new.perform(delivery.id)
      end
    end

    context "with an error in dispatch" do
      before do
        allow_any_instance_of(DeliveryCoordinator).to receive(:dispatch!).and_raise(StandardError.new("Unexpected error"))
      end

      it "re-raises the error" do
        expect {
          described_class.new.perform(delivery.id)
        }.to raise_error(StandardError, "Unexpected error")
      end

      it "reports to sentry" do
        expect(Sentry).to receive(:capture_exception).with(instance_of(StandardError), extra: hash_including(:delivery_id))
        expect {
          described_class.new.perform(delivery.id)
        }.to raise_error(StandardError)
      end
    end
  end
end
