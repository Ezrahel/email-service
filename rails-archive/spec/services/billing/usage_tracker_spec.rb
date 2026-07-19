require "rails_helper"

RSpec.describe Billing::UsageTracker, type: :service do
  let(:organization) { create(:organization) }

  describe "#call" do
    context "with email.sent action" do
      it "creates an hourly usage record" do
        expect {
          described_class.new(organization: organization, action: "email.sent", count: 5).call
        }.to change(UsageRecord, :count).by(1)
      end

      it "increments the count for existing records" do
        described_class.new(organization: organization, action: "email.sent", count: 5).call
        described_class.new(organization: organization, action: "email.sent", count: 3).call
        record = UsageRecord.for_organization(organization)
          .for_metric("emails_sent")
          .last
        expect(record.count).to eq(8)
      end

      it "tracks cost for billable actions" do
        described_class.new(organization: organization, action: "email.sent", count: 10).call
        record = UsageRecord.for_organization(organization)
          .for_metric("emails_sent")
          .last
        expect(record.cost).to be > 0
      end
    end

    context "with api.call action" do
      it "creates a usage record for API calls" do
        expect {
          described_class.new(organization: organization, action: "api.call", count: 1).call
        }.to change(UsageRecord, :count).by(1)
      end

      it "tracks API calls as non-billable" do
        described_class.new(organization: organization, action: "api.call", count: 100).call
        record = UsageRecord.for_organization(organization)
          .for_metric("api_calls")
          .last
        expect(record.cost).to eq(0)
      end
    end

    context "with unknown action" do
      it "raises ArgumentError" do
        expect {
          described_class.new(organization: organization, action: "unknown.action").call
        }.to raise_error(ArgumentError)
      end
    end
  end

  describe ".track_send" do
    it "creates usage record with email.sent action" do
      expect {
        described_class.track_send(organization: organization)
      }.to change(UsageRecord, :count).by(1)
    end
  end
end
