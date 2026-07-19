require "rails_helper"

RSpec.describe BillingAggregationWorker, type: :job do
  describe "#perform" do
    let!(:organization) { create(:organization) }

    it "aggregates billing for all organizations" do
      expect(Billing::BillingAggregator).to receive(:call).with(organization: organization).and_call_original
      subject.perform
    end
  end
end
