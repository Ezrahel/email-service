require "rails_helper"

RSpec.describe AuthService, type: :service do
  describe ".authenticate" do
    let(:organization) { create(:organization) }
    let(:user) { create(:user) }
    let!(:membership) { create(:membership, organization: organization, user: user) }

    context "with valid API key" do
      let(:raw_key) { "em_test_#{SecureRandom.hex(16)}" }
      let!(:api_key) do
        create(:api_key, organization: organization, user: user,
               key_digest: Digest::SHA256.hexdigest(raw_key))
      end

      it "succeeds" do
        request = double(authorization: "Bearer #{raw_key}")
        result = described_class.authenticate(request)

        expect(result).to be_success
        expect(result.organization).to eq(organization)
        expect(result.api_key).to eq(api_key)
      end
    end

    context "without token" do
      it "fails" do
        request = double(authorization: nil)
        result = described_class.authenticate(request)

        expect(result).not_to be_success
        expect(result.error).to eq("Missing API key")
      end
    end

    context "with expired key" do
      let!(:api_key) do
        create(:api_key, organization: organization, user: user,
               expires_at: 1.day.ago)
      end

      it "fails" do
        request = double(authorization: "Bearer test-key")
        allow(Digest::SHA256).to receive(:hexdigest).and_return(api_key.key_digest)
        result = described_class.authenticate(request)

        expect(result).not_to be_success
      end
    end
  end
end
