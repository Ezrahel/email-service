require "rails_helper"

RSpec.describe Dashboard::Usage, type: :service do
  let(:organization) { create(:organization) }

  before do
    create(:usage_record, organization: organization, metric: "emails_sent", count: 100, billable_count: 100, cost: 0.10, granularity: "daily", bucket: 1.day.ago.beginning_of_day)
    create(:usage_record, organization: organization, metric: "api_calls", count: 500, billable_count: 0, cost: 0, granularity: "daily", bucket: 1.day.ago.beginning_of_day)
  end

  subject { described_class.call(organization: organization, since: 7.days.ago, until_time: Time.current, granularity: "daily") }

  describe "#call" do
    it "returns summary with totals" do
      expect(subject[:summary][:total_api_calls]).to eq(500)
      expect(subject[:summary][:estimated_cost]).to be > 0
    end

    it "returns time series data" do
      expect(subject[:time_series]).to be_an(Array)
      if subject[:time_series].any?
        expect(subject[:time_series].first).to have_key(:bucket)
        expect(subject[:time_series].first).to have_key(:total_usage)
      end
    end

    it "returns breakdown by metric" do
      expect(subject[:by_metric]).to be_an(Array)
      metrics = subject[:by_metric].map { |m| m[:metric] }
      expect(metrics).to include("emails_sent")
      expect(metrics).to include("api_calls")
    end
  end
end
