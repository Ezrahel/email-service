require "rails_helper"

RSpec.describe Alerting::AlertEngine, type: :service do
  let(:organization) { create(:organization) }

  describe "#call" do
    subject { described_class.call(organization: organization) }

    it "returns evaluation results" do
      result = subject
      expect(result).to have_key(:evaluated)
      expect(result).to have_key(:dispatched)
      expect(result).to have_key(:alerts)
    end

    context "when quota is exceeded" do
      before do
        allow(organization).to receive(:monthly_email_quota).and_return(10)
        create_list(:email_message, 15, organization: organization, status: "delivered",
                    created_at: Time.current.beginning_of_month + 1.hour)
      end

      it "detects quota exceeded" do
        alerts = subject[:alerts]
        quota_alerts = alerts.select { |a| a[:type] == :quota_exceeded }
        expect(quota_alerts).not_to be_empty
      end
    end

    context "with provider outage" do
      let!(:config) { create(:provider_config, organization: organization, provider_type: "ses", is_active: true) }
      let(:email) { create(:email_message, organization: organization) }
      let(:delivery) { create(:delivery, email_message: email) }

      before do
        create_list(:provider_attempt, 10, delivery: delivery, provider: "ses", status: "failed", created_at: 2.minutes.ago)
      end

      it "detects provider outage" do
        alerts = subject[:alerts]
        outage_alerts = alerts.select { |a| a[:type] == :provider_outage }
        expect(outage_alerts).not_to be_empty
      end
    end

    context "with delivery degradation" do
      before do
        create_list(:email_message, 20, organization: organization, status: "failed", created_at: 2.minutes.ago)
      end

      it "detects delivery degradation" do
        alerts = subject[:alerts]
        degradation = alerts.select { |a| a[:type] == :delivery_degradation }
        expect(degradation).not_to be_empty
      end
    end

    context "with cooldown" do
      before do
        allow(Rails.cache).to receive(:read).and_return(Time.current.iso8601)
      end

      it "deduplicates alerts within cooldown period" do
        result = subject
        expect(result[:dispatched]).to eq(0)
      end
    end
  end
end
