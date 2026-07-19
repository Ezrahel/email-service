require "rails_helper"

RSpec.describe Analytics::DeliverabilityAnalyzer, type: :service do
  let(:organization) { create(:organization) }
  let(:domain) { create(:domain, organization: organization, is_verified: true) }

  before do
    create_list(:email_message, 10, organization: organization, status: "delivered", created_at: 1.day.ago)
    create_list(:email_message, 2, organization: organization, status: "failed", created_at: 1.day.ago)
    create_list(:email_message, 1, organization: organization, status: "bounced", created_at: 1.day.ago)
  end

  subject { described_class.call(organization: organization) }

  describe "#call" do
    it "returns a hash with overview, by_provider, by_domain, trend" do
      result = subject
      expect(result).to have_key(:overview)
      expect(result).to have_key(:by_provider)
      expect(result).to have_key(:by_domain)
      expect(result).to have_key(:trend)
    end

    it "calculates correct totals in overview" do
      overview = subject[:overview]
      expect(overview[:total_sent]).to eq(13)
      expect(overview[:delivered]).to eq(10)
      expect(overview[:failed]).to eq(2)
      expect(overview[:bounced]).to eq(1)
    end

    it "calculates rates correctly" do
      overview = subject[:overview]
      expect(overview[:delivery_rate]).to be > 0
      expect(overview[:bounce_rate]).to be > 0
    end

    it "groups by domain" do
      domains = subject[:by_domain]
      expect(domains).to be_an(Array)
      expect(domains.first).to have_key(:domain)
      expect(domains.first).to have_key(:delivery_rate)
    end

    it "includes daily trend" do
      trend = subject[:trend]
      expect(trend).to be_an(Array)
      expect(trend.first).to have_key(:date)
      expect(trend.first).to have_key(:total)
    end

    it "includes recommendations" do
      expect(subject).to have_key(:recommendations)
    end
  end
end
