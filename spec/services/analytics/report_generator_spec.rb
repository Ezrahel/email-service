require "rails_helper"

RSpec.describe Analytics::ReportGenerator, type: :service do
  let(:organization) { create(:organization) }
  let(:domain) { create(:domain, organization: organization, is_verified: true) }

  before do
    create_list(:email_message, 5, organization: organization, status: "delivered", created_at: 1.day.ago)
  end

  describe "#call" do
    context "with delivery_summary report type" do
      subject { described_class.call(organization: organization, report_type: "delivery_summary") }

      it "returns delivery summary data" do
        result = subject
        expect(result[:report_type]).to eq("delivery_summary")
        expect(result[:totals][:total]).to eq(5)
        expect(result[:totals][:by_status]["delivered"]).to eq(5)
      end
    end

    context "with engagement report type" do
      subject { described_class.call(organization: organization, report_type: "engagement") }

      it "returns engagement data" do
        result = subject
        expect(result[:report_type]).to eq("engagement")
        expect(result).to have_key(:opens)
        expect(result).to have_key(:clicks)
      end
    end

    context "with provider_performance report type" do
      subject { described_class.call(organization: organization, report_type: "provider_performance") }

      it "returns provider stats" do
        result = subject
        expect(result[:report_type]).to eq("provider_performance")
        expect(result).to have_key(:providers)
      end
    end

    context "with compliance report type" do
      subject { described_class.call(organization: organization, report_type: "compliance") }

      it "returns compliance data" do
        result = subject
        expect(result[:report_type]).to eq("compliance")
        expect(result).to have_key(:bounces)
      end
    end

    context "with unknown report type" do
      it "raises ArgumentError" do
        expect {
          described_class.call(organization: organization, report_type: "unknown")
        }.to raise_error(ArgumentError)
      end
    end

    context "with CSV format" do
      subject { described_class.call(organization: organization, report_type: "delivery_summary", format: "csv") }

      it "returns CSV string" do
        result = subject
        expect(result).to be_a(String)
        expect(result).to include("report_type")
      end
    end

    context "with unknown format" do
      it "raises ArgumentError" do
        expect {
          described_class.call(organization: organization, report_type: "delivery_summary", format: "xml")
        }.to raise_error(ArgumentError)
      end
    end
  end
end
