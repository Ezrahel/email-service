RSpec.describe RetryScheduler do
  let(:delivery) { create(:delivery, status: "failed", attempt_count: 1, max_attempts: 3) }

  describe ".schedule" do
    it "resets status to pending" do
      described_class.schedule(delivery)
      expect(delivery.reload.status).to eq("pending")
    end

    it "enqueues EmailDispatchWorker" do
      expect {
        described_class.schedule(delivery)
      }.to change(EmailDispatchWorker.jobs, :size).by(1)
    end

    it "does not schedule non-retryable deliveries" do
      delivery.update!(attempt_count: 5, max_attempts: 3)
      expect {
        described_class.schedule(delivery)
      }.not_to change(EmailDispatchWorker.jobs, :size)
    end
  end
end
