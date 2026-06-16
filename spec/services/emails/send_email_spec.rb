require "rails_helper"

RSpec.describe Emails::SendEmail, type: :service do
  let(:organization) { create(:organization) }
  let(:domain) { create(:domain, organization: organization, is_verified: true) }
  let(:params) do
    {
      from: "sender@#{domain.domain}",
      to: ["recipient@example.com"],
      subject: "Test Subject",
      html: "<h1>Hello</h1>",
      text: "Hello",
      tags: [{ name: "test", value: "true" }]
    }
  end

  describe "#call" do
    it "creates an email message" do
      result = described_class.call(organization: organization, params: params)

      expect(result.email).to be_persisted
      expect(result.email.status).to eq("queued")
      expect(result.email.subject).to eq("Test Subject")
    end

    it "creates a delivery record" do
      expect {
        described_class.call(organization: organization, params: params)
      }.to change(Delivery, :count).by(1)
    end

    it "creates a usage record" do
      expect {
        described_class.call(organization: organization, params: params)
      }.to change(UsageRecord, :count).by(1)
    end

    it "creates an audit log" do
      expect {
        described_class.call(organization: organization, params: params)
      }.to change(AuditLog, :count).by(1)
    end

    context "with unverified domain" do
      let(:unverified_domain) { create(:domain, organization: organization, is_verified: false) }
      let(:params_with_unverified) { params.merge(from: "sender@#{unverified_domain.domain}") }

      it "raises validation error" do
        expect {
          described_class.call(organization: organization, params: params_with_unverified)
        }.to raise_error(Errors::ValidationError)
      end
    end

    context "with idempotency key" do
      it "raises error on duplicate key" do
        described_class.call(
          organization: organization,
          params: params,
          idempotency_key: "dup-key"
        )

        expect {
          described_class.call(
            organization: organization,
            params: params,
            idempotency_key: "dup-key"
          )
        }.to raise_error(Errors::IdempotencyError)
      end
    end

    context "when over quota" do
      before { organization.update!(monthly_email_sent: organization.monthly_email_quota) }

      it "raises quota exceeded error" do
        expect {
          described_class.call(organization: organization, params: params)
        }.to raise_error(Errors::QuotaExceededError)
      end
    end
  end
end
