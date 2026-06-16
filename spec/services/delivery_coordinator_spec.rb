RSpec.describe DeliveryCoordinator do
  let(:organization) { create(:organization) }
  let(:email_message) { create(:email_message, organization: organization, status: "queued") }
  let(:provider_config) { create(:provider_config, organization: organization, provider_type: "ses") }
  let(:delivery) do
    create(:delivery,
      email_message: email_message,
      organization: organization,
      provider_config: provider_config,
      provider: "ses",
      status: "pending",
      attempt_count: 0,
      max_attempts: 3
    )
  end

  let(:adapter_result) do
    double("AdapterResult", success?: true, provider_message_id: "aws-msg-123", duration_ms: 450, error: nil, error_code: nil)
  end

  let(:adapter) { double("ProviderAdapter", send_email: adapter_result) }

  before do
    allow(provider_config).to receive(:adapter).and_return(adapter)
    allow(ProviderRouter).to receive(:select_provider).and_return(
      ProviderRouter::ProviderSelection.new(provider_config: provider_config, provider_type: "ses")
    )
  end

  describe "#dispatch!" do
    context "when delivery succeeds" do
      it "marks delivery as delivered" do
        coordinator = described_class.new(delivery: delivery)
        result = coordinator.dispatch!

        expect(result.success?).to be true
        expect(delivery.reload.status).to eq("delivered")
        expect(delivery.delivered_at).to be_present
      end

      it "records the provider message id" do
        coordinator = described_class.new(delivery: delivery)
        result = coordinator.dispatch!

        expect(result.provider_message_id).to eq("aws-msg-123")
        expect(delivery.reload.provider_message_id).to eq("aws-msg-123")
      end

      it "marks the email as delivered" do
        coordinator = described_class.new(delivery: delivery)
        coordinator.dispatch!

        expect(email_message.reload.status).to eq("delivered")
      end

      it "publishes email.delivered event" do
        expect(EventPublisher).to receive(:publish).with(
          hash_including(event_type: "email.delivered", organization_id: organization.id)
        )

        coordinator = described_class.new(delivery: delivery)
        coordinator.dispatch!
      end
    end

    context "when delivery fails and failover exists" do
      let(:failover_config) { create(:provider_config, organization: organization, provider_type: "sendgrid", priority: 2) }
      let(:failover_result) do
        double("FailoverResult", success?: false, error: "SendGrid down", error_code: nil)
      end
      let(:failover_adapter) { double("FailoverAdapter", send_email: failover_result) }

      before do
        allow(adapter).to receive(:send_email).and_return(
          double("Result", success?: false, provider_message_id: nil, duration_ms: 200, error: "SES timeout", error_code: "TIMEOUT")
        )
        allow(ProviderRouter).to receive(:select_failover).and_return(
          ProviderRouter::ProviderSelection.new(provider_config: failover_config, provider_type: "sendgrid")
        )
        allow(failover_config).to receive(:adapter).and_return(failover_adapter)
      end

      it "schedules a failover dispatch" do
        expect {
          coordinator = described_class.new(delivery: delivery)
          coordinator.dispatch!
        }.to change(EmailDispatchWorker.jobs, :size).by(1)
      end

      it "returns success with failover_scheduled? true" do
        coordinator = described_class.new(delivery: delivery)
        result = coordinator.dispatch!

        expect(result.success?).to be true
        expect(result.failover_scheduled?).to be true
        expect(delivery.reload.status).to eq("pending")
      end
    end

    context "when all providers fail and retries exhausted" do
      before do
        allow(adapter).to receive(:send_email).and_return(
          double("Result", success?: false, provider_message_id: nil, duration_ms: 200, error: "SES timeout", error_code: "TIMEOUT")
        )
        allow(ProviderRouter).to receive(:select_failover).and_return(nil)
      end

      it "marks delivery as failed" do
        coordinator = described_class.new(delivery: delivery)
        result = coordinator.dispatch!

        expect(result.success?).to be false
        expect(delivery.reload.status).to eq("failed")
      end

      it "publishes email.failed event" do
        expect(EventPublisher).to receive(:publish).with(
          hash_including(event_type: "email.failed", organization_id: organization.id)
        )

        coordinator = described_class.new(delivery: delivery)
        coordinator.dispatch!
      end
    end

    context "when delivery is not retryable" do
      before do
        delivery.update!(attempt_count: 5, max_attempts: 3, status: "failed")
      end

      it "returns failure immediately" do
        coordinator = described_class.new(delivery: delivery)
        result = coordinator.dispatch!

        expect(result.success?).to be false
        expect(result.error).to eq("Not retryable")
      end

      it "does not attempt to send" do
        expect(adapter).not_to receive(:send_email)

        coordinator = described_class.new(delivery: delivery)
        coordinator.dispatch!
      end
    end

    context "with no available providers" do
      before do
        allow(ProviderRouter).to receive(:select_provider).and_return(nil)
      end

      it "marks delivery as failed" do
        coordinator = described_class.new(delivery: delivery)
        result = coordinator.dispatch!

        expect(result.success?).to be false
        expect(delivery.reload.status).to eq("failed")
        expect(delivery.failure_reason).to eq("No provider available")
      end
    end
  end
end
