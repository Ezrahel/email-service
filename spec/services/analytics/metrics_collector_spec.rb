require "rails_helper"

RSpec.describe Analytics::MetricsCollector, type: :service do
  subject { described_class.call }

  describe "#call" do
    it "returns a hash with metrics keys" do
      result = subject
      expect(result).to have_key(:queued)
      expect(result).to have_key(:processed)
      expect(result).to have_key(:rates)
      expect(result).to have_key(:latency)
      expect(result).to have_key(:timestamp)
    end

    it "includes queue metrics" do
      expect(subject[:queued]).to have_key(:enqueued)
      expect(subject[:queued]).to have_key(:retry_count)
      expect(subject[:queued]).to have_key(:processes)
    end

    it "includes processing metrics per queue" do
      expect(subject[:processed]).to have_key("default")
    end

    it "includes rate metrics" do
      expect(subject[:rates]).to have_key(:messages_per_minute)
      expect(subject[:rates]).to have_key(:delivery_rate)
    end

    it "includes latency metrics" do
      expect(subject[:latency]).to have_key(:avg_ms)
      expect(subject[:latency]).to have_key(:p50_ms)
    end

    context "when sidekiq is unavailable" do
      before do
        allow(Sidekiq::Stats).to receive(:new).and_raise(StandardError.new("connection error"))
      end

      it "gracefully handles errors" do
        expect(subject[:queued][:error]).to eq("connection error")
      end
    end
  end
end
