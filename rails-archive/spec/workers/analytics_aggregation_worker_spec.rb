require "rails_helper"

RSpec.describe AnalyticsAggregationWorker, type: :job do
  describe "#perform" do
    it "calls EventAggregator with the given window" do
      expect(Analytics::EventAggregator).to receive(:new).with(window: "1h").and_call_original
      expect_any_instance_of(Analytics::EventAggregator).to receive(:call)
      subject.perform("1h")
    end

    it "calls UsageAggregator for hourly window" do
      expect(Analytics::UsageAggregator).to receive(:call)
      subject.perform("1h")
    end

    it "does not call UsageAggregator for sub-hour windows" do
      expect(Analytics::UsageAggregator).not_to receive(:call)
      subject.perform("1m")
    end
  end
end
