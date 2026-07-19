require "rails_helper"

RSpec.describe Monitoring::HealthService, type: :service do
  describe "#call" do
    subject { described_class.call }

    it "returns overall status" do
      expect(subject).to have_key(:status)
      expect(subject).to have_key(:timestamp)
    end

    it "includes all health checks" do
      expect(subject[:checks]).to have_key(:database)
      expect(subject[:checks]).to have_key(:redis)
      expect(subject[:checks]).to have_key(:sidekiq)
      expect(subject[:checks]).to have_key(:providers)
      expect(subject[:checks]).to have_key(:system)
    end

    it "reports database health" do
      expect(subject[:checks][:database][:healthy]).to be true
    end
  end

  describe "#liveness" do
    it "returns alive status" do
      result = described_class.new.liveness
      expect(result[:status]).to eq("alive")
      expect(result).to have_key(:uptime)
    end
  end

  describe "#readiness" do
    it "returns readiness status" do
      result = described_class.new.readiness
      expect(result).to have_key(:status)
      expect(result[:checks]).to have_key("database")
      expect(result[:checks]).to have_key("redis")
    end
  end
end
