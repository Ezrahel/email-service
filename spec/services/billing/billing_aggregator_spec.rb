require "rails_helper"

RSpec.describe Billing::BillingAggregator, type: :service do
  let(:organization) { create(:organization, plan: "free") }

  before do
    create(:usage_record, organization: organization, metric: "emails_sent", count: 500, billable_count: 500,
           cost: 0.50, granularity: "daily", bucket: 2.days.ago.beginning_of_day)
  end

  describe "#call" do
    subject {
      described_class.call(
        organization: organization,
        billing_period_start: 30.days.ago.beginning_of_month,
        billing_period_end: Time.current.end_of_month
      )
    }

    it "returns period info" do
      expect(subject[:period]).to have_key(:start)
      expect(subject[:period]).to have_key(:end)
    end

    it "aggregates usage data" do
      expect(subject[:usage][:emails_sent]).to be >= 500
    end

    it "calculates costs" do
      expect(subject[:costs]).to have_key(:email_cost)
      expect(subject[:costs]).to have_key(:base_plan)
    end

    it "calculates total cost" do
      expect(subject[:total_cost]).to be >= 0
    end
  end
end
