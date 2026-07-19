require "rails_helper"

RSpec.describe Monitoring::DeliveryHealthMonitor, type: :service do
  let(:organization) { create(:organization) }
  let(:domain) { create(:domain, organization: organization, is_verified: true) }

  describe "#call" do
    context "with a single organization" do
      subject { described_class.call(organization: organization) }

      before do
        create_list(:email_message, 5, organization: organization, status: "delivered", created_at: 30.minutes.ago)
      end

      it "returns organization delivery data" do
        result = subject
        expect(result[:organizations]).to be_an(Array)
        org_data = result[:organizations].first
        expect(org_data[:total_sent]).to eq(5)
        expect(org_data[:delivered]).to eq(5)
        expect(org_data[:status]).to eq("healthy")
      end

      it "includes global summary" do
        expect(subject[:global]).to have_key(:total_sent)
        expect(subject[:global]).to have_key(:healthy_orgs)
      end
    end

    context "with degraded delivery" do
      subject { described_class.call(organization: organization) }

      before do
        create_list(:email_message, 10, organization: organization, status: "failed", created_at: 30.minutes.ago)
      end

      it "reports degraded status" do
        org_data = subject[:organizations].first
        expect(org_data[:status]).to eq("degraded")
      end
    end
  end
end
