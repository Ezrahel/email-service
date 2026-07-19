require "rails_helper"

RSpec.describe Operations::AuditService, type: :service do
  let(:organization) { create(:organization) }
  let(:user) { create(:user) }

  describe "#call" do
    it "creates an audit log entry" do
      expect {
        described_class.call(
          action: "create",
          resource_type: "domain",
          resource_id: SecureRandom.uuid,
          organization: organization,
          user: user,
          metadata: { domain: "example.com" }
        )
      }.to change(AuditLog, :count).by(1)
    end

    it "records the correct action" do
      described_class.call(
        action: "create",
        resource_type: "domain",
        resource_id: SecureRandom.uuid,
        organization: organization
      )
      log = AuditLog.last
      expect(log.action).to eq("create")
      expect(log.resource_type).to eq("domain")
    end

    it "raises error for invalid action" do
      expect {
        described_class.call(
          action: "invalid_action",
          resource_type: "domain",
          organization: organization
        )
      }.to raise_error(ArgumentError)
    end

    it "raises error for invalid resource type" do
      expect {
        described_class.call(
          action: "create",
          resource_type: "invalid_resource",
          organization: organization
        )
      }.to raise_error(ArgumentError)
    end
  end

  describe ".log_send" do
    let(:email) { create(:email_message, organization: organization) }

    it "creates audit log for email send" do
      expect {
        described_class.log_send(organization: organization, email: email)
      }.to change(AuditLog, :count).by(1)
    end
  end

  describe ".log_domain_change" do
    let(:domain) { create(:domain, organization: organization) }

    it "creates audit log for domain change" do
      expect {
        described_class.log_domain_change(organization: organization, domain: domain, action: "verify")
      }.to change(AuditLog, :count).by(1)
    end
  end

  describe ".log_api_key_action" do
    let(:api_key) { create(:api_key, organization: organization) }

    it "creates audit log for API key action" do
      expect {
        described_class.log_api_key_action(organization: organization, api_key: api_key, action: "revoke")
      }.to change(AuditLog, :count).by(1)
    end
  end
end
