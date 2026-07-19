require "rails_helper"

RSpec.describe AlertEvaluationWorker, type: :job do
  describe "#perform" do
    let!(:org1) { create(:organization) }
    let!(:org2) { create(:organization) }

    it "evaluates alerts for all organizations" do
      expect(Alerting::AlertEngine).to receive(:call).with(organization: org1).and_call_original
      expect(Alerting::AlertEngine).to receive(:call).with(organization: org2).and_call_original
      subject.perform
    end

    it "handles errors gracefully" do
      expect(Organization).to receive(:find_each).and_yield(org1).and_raise(StandardError.new("test error"))
      expect { subject.perform }.not_to raise_error
    end
  end
end
