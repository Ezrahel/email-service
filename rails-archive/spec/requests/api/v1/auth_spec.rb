require "rails_helper"

RSpec.describe "Api::V1::Auth", type: :request do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, password: "testpass123") }
  let!(:membership) { create(:membership, organization: organization, user: user) }
  let(:api_key) { create(:api_key, organization: organization, user: user) }
  let(:auth_header) { { "Authorization" => "Bearer test-key", "Content-Type" => "application/json" } }

  before do
    allow_any_instance_of(ApiKey).to receive(:touch)
  end

  describe "POST /api/v1/auth/login" do
    it "returns JWT token with valid credentials" do
      post "/api/v1/auth/login", params: { email: user.email, password: "testpass123" }.to_json,
           headers: { "Content-Type" => "application/json" }

      expect(response).to have_http_status(:ok)
      expect(json_body.dig("data", "token")).to be_present
      expect(json_body.dig("data", "refresh_token")).to be_present
    end

    it "returns 401 with invalid credentials" do
      post "/api/v1/auth/login", params: { email: user.email, password: "wrong" }.to_json,
           headers: { "Content-Type" => "application/json" }

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "POST /api/v1/auth/refresh" do
    it "returns 401 with invalid refresh token" do
      post "/api/v1/auth/refresh", params: { refresh_token: "invalid" }.to_json,
           headers: { "Content-Type" => "application/json" }

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "API Key Authentication" do
    it "authenticates via Bearer token" do
      get "/api/v1/organization", headers: auth_header

      expect(response).to have_http_status(:ok)
    end

    it "rejects requests without auth" do
      get "/api/v1/organization"

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
