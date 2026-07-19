require "rails_helper"

RSpec.describe Domains::CreateDomain, type: :service do
  let(:organization) { create(:organization) }
  let(:params) { { domain: "example.com", region: "us" } }

  describe "#call" do
    it "creates a domain" do
      result = described_class.call(organization: organization, params: params)

      expect(result.domain).to be_persisted
      expect(result.domain.domain).to eq("example.com")
    end

    it "generates DNS records" do
      result = described_class.call(organization: organization, params: params)

      expect(result.domain.dns_records.count).to eq(4)
      expect(result.domain.dns_records.pluck(:record_type)).to match_array(%w[TXT TXT TXT MX])
    end

    it "sets verification token" do
      result = described_class.call(organization: organization, params: params)

      expect(result.domain.verification_token).to be_present
    end
  end
end
