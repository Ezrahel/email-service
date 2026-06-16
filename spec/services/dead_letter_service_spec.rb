RSpec.describe DeadLetterService do
  let(:organization) { create(:organization) }
  let(:delivery) { create(:delivery, organization: organization, status: "failed", attempt_count: 3, max_attempts: 3, failure_reason: "Provider error") }

  describe ".send" do
    it "marks delivery as failed" do
      described_class.send(delivery)
      expect(delivery.reload.status).to eq("failed")
    end
  end

  describe ".replay" do
    it "resets delivery for retry" do
      described_class.replay(delivery.id, organization_id: organization.id)
      delivery.reload

      expect(delivery.status).to eq("pending")
      expect(delivery.attempt_count).to eq(0)
      expect(delivery.failure_reason).to be_nil
    end

    it "enqueues dispatch worker" do
      expect {
        described_class.replay(delivery.id, organization_id: organization.id)
      }.to change(EmailDispatchWorker.jobs, :size).by(1)
    end

    it "raises on organization mismatch" do
      other_org = create(:organization)
      expect {
        described_class.replay(delivery.id, organization_id: other_org.id)
      }.to raise_error(Errors::ForbiddenError)
    end
  end

  describe ".list" do
    it "returns dead-lettered deliveries" do
      delivery # create it
      list = described_class.list(organization_id: organization.id, limit: 10)
      expect(list).to include(delivery)
    end
  end
end
