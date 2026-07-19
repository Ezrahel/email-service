require "rails_helper"

RSpec.describe Dashboard::Overview, type: :service do
  let(:organization) { create(:organization) }
  let(:domain) { create(:domain, organization: organization, is_verified: true) }

  before do
    create_list(:email_message, 5, organization: organization, status: "delivered", created_at: 1.day.ago)
    create_list(:email_message, 1, organization: organization, status: "failed", created_at: 1.day.ago)
    create_list(:email_message, 1, organization: organization, status: "bounced", created_at: 1.day.ago)
  end

  subject { described_class.call(organization: organization, since: 7.days.ago, until_time: Time.current) }

  describe "#call" do
    it "returns period information" do
      expect(subject[:period]).to have_key(:since)
      expect(subject[:period]).to have_key(:until)
    end

    it "returns totals with correct counts" do
      totals = subject[:totals]
      expect(totals[:sent]).to eq(7)
      expect(totals[:delivered]).to eq(5)
      expect(totals[:failed]).to eq(1)
      expect(totals[:bounced]).to eq(1)
    end

    it "returns rates" do
      expect(subject[:rates]).to have_key(:delivery)
      expect(subject[:rates]).to have_key(:bounce)
    end

    it "includes current_hour data" do
      expect(subject[:current_hour]).to have_key(:sent)
      expect(subject[:current_hour]).to have_key(:failed)
    end

    it "includes top domains" do
      expect(subject[:top_domains]).to be_an(Array)
    end

    it "includes 30 day trend" do
      expect(subject[:trend]).to be_an(Array)
      expect(subject[:trend].first).to have_key(:date) if subject[:trend].any?
    end
  end
end
