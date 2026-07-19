require "rails_helper"

RSpec.describe DataRetentionWorker, type: :job do
  describe "#perform" do
    it "executes without error" do
      expect { subject.perform }.not_to raise_error
    end

    it "calls retention policy enforcement" do
      expect(subject).to receive(:enforce_retention_policies!)
      subject.perform
    end

    it "calls rollup cleanup" do
      expect(subject).to receive(:cleanup_rollup_tables!)
      subject.perform
    end
  end
end
