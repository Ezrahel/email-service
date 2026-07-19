require "rails_helper"

RSpec.describe Operations::AdminOperations, type: :service do
  let(:organization) { create(:organization) }
  let(:domain) { create(:domain, organization: organization, is_verified: true) }

  subject { described_class.new }

  describe "#replay_delivery" do
    let(:email) { create(:email_message, organization: organization, status: "failed") }

    it "re-queues a failed email" do
      expect {
        result = subject.replay_delivery(email_message_id: email.id)
        expect(result[:replayed]).to be true
      }.to change { email.reload.status }.to("queued")
    end

    it "creates an audit log" do
      expect {
        subject.replay_delivery(email_message_id: email.id)
      }.to change(AuditLog, :count).by(1)
    end
  end

  describe "#cancel_email" do
    let(:email) { create(:email_message, organization: organization, status: "queued") }

    it "cancels a queued email" do
      result = subject.cancel_email(email_message_id: email.id)
      expect(result[:cancelled]).to be true
      expect(email.reload.status).to eq("cancelled")
    end

    it "raises error for delivered email" do
      email.update!(status: "delivered")
      expect {
        subject.cancel_email(email_message_id: email.id)
      }.to raise_error("Cannot cancel delivered email")
    end
  end

  describe "#pause_provider / #resume_provider" do
    let!(:config) { create(:provider_config, organization: organization, is_active: true) }

    it "pauses and resumes a provider" do
      result = subject.pause_provider(provider_config_id: config.id)
      expect(result[:paused]).to be true
      expect(config.reload.is_active).to be false

      result = subject.resume_provider(provider_config_id: config.id)
      expect(result[:resumed]).to be true
      expect(config.reload.is_active).to be true
    end
  end

  describe "#resend_webhook" do
    let(:webhook) { create(:webhook, organization: organization) }
    let!(:delivery) { create(:webhook_delivery, webhook: webhook) }

    it "enqueues a webhook resend" do
      expect {
        subject.resend_webhook(webhook_delivery_id: delivery.id)
      }.to change(AuditLog, :count).by(1)
    end
  end
end
