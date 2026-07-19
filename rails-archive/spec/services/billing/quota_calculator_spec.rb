require "rails_helper"

RSpec.describe Billing::QuotaCalculator, type: :service do
  let(:organization) { create(:organization, monthly_email_quota: 1000) }

  describe "#call" do
    subject { described_class.call(organization: organization) }

    it "returns plan info" do
      expect(subject[:plan]).to eq("free")
    end

    it "returns limits" do
      expect(subject[:limits][:monthly_emails]).to eq(1000)
      expect(subject[:limits]).to have_key(:api_rate_per_second)
    end

    it "returns current usage" do
      expect(subject[:current_usage]).to have_key(:monthly_emails_sent)
      expect(subject[:current_usage]).to have_key(:api_calls_this_month)
    end

    it "returns usage percentages" do
      expect(subject[:percentages]).to have_key(:email_usage)
      expect(subject[:percentages]).to have_key(:storage_usage)
    end

    it "returns remaining resources" do
      expect(subject[:remaining][:emails]).to be > 0
    end

    context "with partial quota usage" do
      before do
        create_list(:email_message, 100, organization: organization, created_at: Time.current.beginning_of_month + 1.hour)
      end

      it "calculates correct percentages" do
        expect(subject[:current_usage][:monthly_emails_sent]).to eq(100)
        expect(subject[:percentages][:email_usage]).to eq(10.0)
      end
    end
  end
end
