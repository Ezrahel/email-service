require "rails_helper"

RSpec.describe Dashboard::ProviderPerformance, type: :service do
  let(:organization) { create(:organization) }
  let(:email_message) { create(:email_message, organization: organization, status: "delivered") }
  let(:delivery) { create(:delivery, email_message: email_message) }

  before do
    create(:provider_attempt, delivery: delivery, provider: "ses", status: "success", duration_ms: 150)
    create(:provider_attempt, delivery: delivery, provider: "ses", status: "success", duration_ms: 200)
    create(:provider_attempt, delivery: delivery, provider: "sendgrid", status: "success", duration_ms: 300)
    create(:provider_attempt, delivery: delivery, provider: "sendgrid", status: "failed", duration_ms: 500)
  end

  subject { described_class.call(organization: organization, since: 7.days.ago, until_time: Time.current) }

  describe "#call" do
    it "returns provider list" do
      expect(subject[:providers]).to be_an(Array)
    end

    it "includes totals" do
      expect(subject[:totals]).to have_key(:total_attempts)
      expect(subject[:totals][:total_attempts]).to eq(4)
    end

    it "includes provider health data" do
      expect(subject[:health]).to be_an(Array)
    end

    it "calculates per-provider stats" do
      ses = subject[:providers].find { |p| p[:provider] == "ses" }
      expect(ses).not_to be_nil
      expect(ses[:success_count]).to eq(2)
      expect(ses[:success_rate]).to eq(100.0)
    end
  end
end
