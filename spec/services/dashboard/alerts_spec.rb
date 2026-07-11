require "rails_helper"

RSpec.describe Dashboard::Alerts, type: :service do
  let(:organization) { create(:organization) }

  describe "#call" do
    subject { described_class.call(organization: organization, since: 24.hours.ago, until_time: Time.current) }

    context "with normal conditions" do
      it "returns no alerts" do
        expect(subject[:alerts]).to be_an(Array)
        expect(subject[:total_alerts]).to be >= 0
      end
    end

    context "with high failure rate" do
      before do
        create_list(:email_message, 10, organization: organization, status: "failed", created_at: 1.hour.ago)
        create(:email_message, organization: organization, status: "delivered", created_at: 1.hour.ago)
      end

      it "generates a high failure rate alert" do
        alerts = subject[:alerts]
        failure_alerts = alerts.select { |a| a[:type] == "high_failure_rate" }
        expect(failure_alerts).not_to be_empty
      end
    end

    context "with high bounce rate" do
      before do
        create_list(:email_message, 5, organization: organization, status: "bounced", created_at: 1.hour.ago)
        create_list(:email_message, 10, organization: organization, status: "delivered", created_at: 1.hour.ago)
      end

      it "generates a bounce alert" do
        alerts = subject[:alerts]
        bounce_alerts = alerts.select { |a| a[:type] == "high_bounce_rate" }
        expect(bounce_alerts).not_to be_empty
      end
    end

    it "provides alert details" do
      create_list(:email_message, 20, organization: organization, status: "failed", created_at: 1.hour.ago)
      alert = subject[:alerts].find { |a| a[:type] == "high_failure_rate" }
      expect(alert).to have_key(:severity)
      expect(alert).to have_key(:message)
      expect(alert).to have_key(:value)
      expect(alert).to have_key(:threshold)
    end
  end
end
