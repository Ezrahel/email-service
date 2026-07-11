require "rails_helper"

RSpec.describe Analytics::EventAggregator, type: :service do
  let(:organization) { create(:organization) }
  let(:domain) { create(:domain, organization: organization, is_verified: true) }

  before do
    create_list(:email_message, 5, organization: organization, status: "delivered", created_at: 30.minutes.ago)
    create_list(:email_message, 2, organization: organization, status: "failed", created_at: 30.minutes.ago)
    create_list(:email_message, 1, organization: organization, status: "bounced", created_at: 30.minutes.ago)
  end

  describe "#call" do
    context "with hourly window" do
      subject { described_class.new(window: "1h") }

      it "aggregates email volume" do
        result = subject.call
        expect(result[:aggregated]).to be true
        expect(result[:window]).to eq("1h")
      end

      it "creates aggregate records" do
        expect { subject.call }.to change(Aggregate, :count).by_at_least(1)
      end

      it "records email counts by status" do
        subject.call
        aggregate = Aggregate.for_organization(organization)
          .for_metric("emails_sent")
          .first
        expect(aggregate.total_count).to eq(8)
        expect(aggregate.delivered_count).to eq(5)
        expect(aggregate.failed_count).to eq(2)
      end
    end

    context "with force_replay" do
      it "aggregates from a wider time range" do
        expect_any_instance_of(described_class).to receive(:aggregate_email_volume)
        described_class.new(window: "1h", force_replay: true).call
      end
    end

    context "with unknown window" do
      it "raises ArgumentError" do
        expect { described_class.new(window: "invalid").call }.to raise_error(ArgumentError)
      end
    end
  end

  describe ".replay_all!" do
    it "calls all window sizes" do
      described_class::WINDOWS.keys.each do |w|
        expect_any_instance_of(described_class).to receive(:call)
      end
      described_class.replay_all!
    end
  end
end
