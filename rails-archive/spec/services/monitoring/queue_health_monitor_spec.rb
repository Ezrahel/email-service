require "rails_helper"

RSpec.describe Monitoring::QueueHealthMonitor, type: :service do
  describe "#call" do
    subject { described_class.call }

    it "returns timestamp" do
      expect(subject).to have_key(:timestamp)
    end

    it "returns total enqueued count" do
      expect(subject).to have_key(:total_enqueued)
    end

    it "returns queue details" do
      expect(subject[:queues]).to have_key("default")
      expect(subject[:queues]["default"]).to have_key(:depth)
      expect(subject[:queues]["default"]).to have_key(:latency)
    end

    it "includes worker details" do
      expect(subject[:workers]).to have_key(:total)
      expect(subject[:workers]).to have_key(:by_queue)
    end

    it "includes retry and dead queue details" do
      expect(subject).to have_key(:retries)
      expect(subject).to have_key(:dead)
      expect(subject).to have_key(:alerts)
    end
  end
end
