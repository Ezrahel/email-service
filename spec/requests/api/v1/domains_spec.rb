require "rails_helper"

RSpec.describe "Api::V1::Domains", type: :request do
  let(:organization) { create(:organization) }
  let(:user) { create(:user) }
  let!(:membership) { create(:membership, organization: organization, user: user) }
  let(:api_key) { create(:api_key, organization: organization, user: user) }
  let(:auth_header) { { "Authorization" => "Bearer test-key", "Content-Type" => "application/json" } }

  before do
    allow_any_instance_of(ApiKey).to receive(:touch)
  end

  describe "POST /api/v1/domains" do
    let(:valid_params) { { domain: "example.com", region: "us" } }

    it "creates a domain" do
      expect {
        post "/api/v1/domains", params: valid_params.to_json, headers: auth_header
      }.to change(Domain, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(json_body.dig("data", "domain")).to eq("example.com")
    end

    it "generates DNS records" do
      post "/api/v1/domains", params: valid_params.to_json, headers: auth_header

      domain = Domain.last
      expect(domain.dns_records.count).to be > 0
    end
  end

  describe "GET /api/v1/domains" do
    before { create_list(:domain, 2, organization: organization) }

    it "lists domains" do
      get "/api/v1/domains", headers: auth_header

      expect(response).to have_http_status(:ok)
      expect(json_body["data"].size).to eq(2)
    end
  end

  describe "POST /api/v1/domains/:id/verify" do
    let(:domain) { create(:domain, organization: organization, is_verified: false) }

    it "attempts verification" do
      post "/api/v1/domains/#{domain.id}/verify", headers: auth_header

      expect(response).to have_http_status(:ok)
    end
  end
end
