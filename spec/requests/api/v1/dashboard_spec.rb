require "rails_helper"

RSpec.describe "Dashboard API", type: :request do
  let(:organization) { create(:organization) }
  let(:api_key) { create(:api_key, organization: organization, scopes: ["analytics:read"]) }
  let(:domain) { create(:domain, organization: organization, is_verified: true) }
  let(:auth_headers) { { "Authorization" => "Bearer #{api_key.key}" } }

  before do
    create_list(:email_message, 3, organization: organization, status: "delivered", created_at: 1.day.ago)
    create_list(:email_message, 1, organization: organization, status: "failed", created_at: 1.day.ago)
  end

  describe "GET /api/v1/dashboard/overview" do
    it "returns 200 with overview data" do
      get "/api/v1/dashboard/overview", headers: auth_headers
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body).to have_key("totals")
      expect(body["totals"]["sent"]).to eq(4)
    end

    it "supports since and until params" do
      get "/api/v1/dashboard/overview", headers: auth_headers, params: { since: 7.days.ago.iso8601, until: Time.current.iso8601 }
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /api/v1/dashboard/deliverability" do
    it "returns 200 with deliverability data" do
      get "/api/v1/dashboard/deliverability", headers: auth_headers
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["summary"]).to have_key("total_sent")
    end

    it "supports granularity param" do
      get "/api/v1/dashboard/deliverability", headers: auth_headers, params: { granularity: "hourly" }
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /api/v1/dashboard/usage" do
    it "returns 200 with usage data" do
      get "/api/v1/dashboard/usage", headers: auth_headers
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /api/v1/dashboard/providers" do
    it "returns 200 with provider data" do
      get "/api/v1/dashboard/providers", headers: auth_headers
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /api/v1/dashboard/activity" do
    it "returns 200 with activity data" do
      get "/api/v1/dashboard/activity", headers: auth_headers
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body).to have_key("events")
      expect(body).to have_key("pagination")
    end
  end

  describe "GET /api/v1/dashboard/alerts" do
    it "returns 200 with alerts data" do
      get "/api/v1/dashboard/alerts", headers: auth_headers
      expect(response).to have_http_status(:ok)
    end
  end

  describe "authentication" do
    it "returns 401 without API key" do
      get "/api/v1/dashboard/overview"
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 403 without analytics scope" do
      restricted_key = create(:api_key, organization: organization, scopes: ["email:send"])
      headers = { "Authorization" => "Bearer #{restricted_key.key}" }
      get "/api/v1/dashboard/overview", headers: headers
      expect(response).to have_http_status(:forbidden)
    end
  end
end
