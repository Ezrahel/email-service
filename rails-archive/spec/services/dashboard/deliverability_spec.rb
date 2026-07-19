require "rails_helper"

RSpec.describe Dashboard::Deliverability, type: :service do
  let(:organization) { create(:organization) }
  let(:domain) { create(:domain, organization: organization, is_verified: true) }

  before do
    create_list(:email_message, 8, organization: organization, status: "delivered", created_at: 2.days.ago)
    create_list(:email_message, 2, organization: organization, status: "failed", created_at: 2.days.ago)
  end

  subject { described_class.call(organization: organization, since: 7.days.ago, until_time: Time.current, granularity: "daily") }

  describe "#call" do
    it "returns summary with totals" do
      expect(subject[:summary][:total_sent]).to eq(10)
      expect(subject[:summary][:delivered]).to eq(8)
      expect(subject[:summary][:failed]).to eq(2)
    end

    it "includes time series data" do
      expect(subject[:time_series]).to be_an(Array)
      if subject[:time_series].any?
        expect(subject[:time_series].first).to have_key(:bucket)
        expect(subject[:time_series].first).to have_key(:total)
        expect(subject[:time_series].first).to have_key(:delivery_rate)
      end
    end

    it "includes provider breakdown" do
      expect(subject[:by_provider]).to be_an(Array)
    end

    it "includes domain breakdown" do
      expect(subject[:by_domain]).to be_an(Array)
      if subject[:by_domain].any?
        expect(subject[:by_domain].first).to have_key(:domain)
        expect(subject[:by_domain].first).to have_key(:delivery_rate)
      end
    end

    context "with hourly granularity" do
      subject { described_class.call(organization: organization, since: 24.hours.ago, until_time: Time.current, granularity: "hourly") }

      it "returns hourly buckets" do
        expect(subject[:granularity]).to eq("hourly")
      end
    end
  end
end
