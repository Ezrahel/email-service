require "rails_helper"

RSpec.describe "Api::V1::Templates", type: :request do
  let(:organization) { create(:organization) }
  let(:user) { create(:user) }
  let!(:membership) { create(:membership, organization: organization, user: user) }
  let(:api_key) { create(:api_key, organization: organization, user: user) }
  let(:auth_header) { { "Authorization" => "Bearer test-key", "Content-Type" => "application/json" } }

  before do
    allow_any_instance_of(ApiKey).to receive(:touch)
  end

  describe "POST /api/v1/templates" do
    let(:valid_params) do
      {
        name: "Welcome Email",
        slug: "welcome",
        subject: "Welcome {{ name }}",
        html_body: "<h1>Hello {{ name }}</h1>",
        variables: [{ name: "name", type: "string", required: true }]
      }
    end

    it "creates a template" do
      expect {
        post "/api/v1/templates", params: valid_params.to_json, headers: auth_header
      }.to change(Template, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(json_body.dig("data", "slug")).to eq("welcome")
    end

    it "creates an initial version" do
      post "/api/v1/templates", params: valid_params.to_json, headers: auth_header

      template = Template.last
      expect(template.versions.count).to eq(1)
    end
  end

  describe "GET /api/v1/templates" do
    before { create_list(:template, 2, organization: organization) }

    it "lists templates" do
      get "/api/v1/templates", headers: auth_header

      expect(response).to have_http_status(:ok)
      expect(json_body["data"].size).to eq(2)
    end
  end

  describe "POST /api/v1/templates/:id/send" do
    let(:domain) { create(:domain, organization: organization, is_verified: true) }
    let(:template) { create(:template, organization: organization) }
    let(:send_params) do
      {
        from: "sender@#{domain.domain}",
        to: ["user@example.com"],
        variables: { name: "John" }
      }
    end

    it "sends a template email" do
      expect {
        post "/api/v1/templates/#{template.id}/send", params: send_params.to_json, headers: auth_header
      }.to change(EmailMessage, :count).by(1)

      expect(response).to have_http_status(:created)
    end
  end
end
