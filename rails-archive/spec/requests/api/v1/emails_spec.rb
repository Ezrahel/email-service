require "rails_helper"

RSpec.describe "Api::V1::Emails", type: :request do
  let(:organization) { create(:organization) }
  let(:user) { create(:user) }
  let!(:membership) { create(:membership, organization: organization, user: user) }
  let(:domain) { create(:domain, organization: organization, is_verified: true) }
  let(:api_key) { create(:api_key, organization: organization, user: user) }
  let(:auth_header) { { "Authorization" => "Bearer #{raw_key(api_key)}", "Content-Type" => "application/json" } }

  def raw_key(key_record)
    # Reconstruct the raw key for testing
    "em_test_#{SecureRandom.hex(16)}"
  end

  before do
    # Stub authentication to use our test API key
    allow(Digest::SHA256).to receive(:hexdigest).and_return(api_key.key_digest)
    # Override the digest to match our test key
    allow_any_instance_of(ApiKey).to receive(:touch)
  end

  describe "POST /api/v1/emails" do
    let(:valid_params) do
      {
        from: "sender@#{domain.domain}",
        to: ["recipient@example.com"],
        subject: "Test Email",
        html: "<h1>Hello</h1>",
        text: "Hello",
        tags: [{ name: "test", value: "true" }]
      }
    end

    context "with valid params" do
      it "creates an email and returns 201" do
        expect {
          post "/api/v1/emails", params: valid_params.to_json, headers: auth_header
        }.to change(EmailMessage, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json_body.dig("data", "status")).to eq("queued")
      end

      it "includes the email id in the response" do
        post "/api/v1/emails", params: valid_params.to_json, headers: auth_header

        expect(json_body.dig("data", "id")).to be_present
      end

      it "creates a delivery record" do
        expect {
          post "/api/v1/emails", params: valid_params.to_json, headers: auth_header
        }.to change(Delivery, :count).by(1)
      end
    end

    context "with idempotency key" do
      let(:idempotent_params) { valid_params.merge(idempotency_key: "unique-key-123") }

      it "accepts first request" do
        post "/api/v1/emails", params: idempotent_params.to_json, headers: auth_header
        expect(response).to have_http_status(:created)
      end

      it "rejects duplicate idempotency key" do
        post "/api/v1/emails", params: idempotent_params.to_json, headers: auth_header
        post "/api/v1/emails", params: idempotent_params.to_json, headers: auth_header

        expect(response).to have_http_status(:conflict)
      end
    end

    context "with invalid params" do
      it "returns 422 when from is missing" do
        post "/api/v1/emails", params: valid_params.except(:from).to_json, headers: auth_header

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns 422 when subject is missing" do
        post "/api/v1/emails", params: valid_params.except(:subject).to_json, headers: auth_header

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns 422 when to is empty" do
        post "/api/v1/emails", params: valid_params.merge(to: []).to_json, headers: auth_header

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns 422 when from domain is not verified" do
        params = valid_params.merge(from: "sender@unverified.com")
        post "/api/v1/emails", params: params.to_json, headers: auth_header

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "without authentication" do
      it "returns 401" do
        post "/api/v1/emails", params: valid_params.to_json, headers: { "Content-Type" => "application/json" }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "GET /api/v1/emails/:id" do
    let(:email) { create(:email_message, organization: organization, domain: domain) }

    it "returns the email" do
      get "/api/v1/emails/#{email.id}", headers: auth_header

      expect(response).to have_http_status(:ok)
      expect(json_body.dig("data", "id")).to eq(email.id)
    end

    it "returns a 404 for unknown email" do
      get "/api/v1/emails/00000000-0000-0000-0000-000000000000", headers: auth_header

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /api/v1/emails" do
    before do
      create_list(:email_message, 3, organization: organization, domain: domain)
    end

    it "returns paginated emails" do
      get "/api/v1/emails", headers: auth_header

      expect(response).to have_http_status(:ok)
      expect(json_body["data"]).to be_an(Array)
      expect(json_body.dig("meta", "total")).to eq(3)
    end
  end

  describe "POST /api/v1/emails/batch" do
    let(:batch_params) do
      {
        messages: [
          {
            from: "sender@#{domain.domain}",
            to: ["user1@example.com"],
            subject: "Batch 1",
            html: "<p>1</p>"
          },
          {
            from: "sender@#{domain.domain}",
            to: ["user2@example.com"],
            subject: "Batch 2",
            html: "<p>2</p>"
          }
        ]
      }
    end

    it "creates multiple emails" do
      expect {
        post "/api/v1/emails/batch", params: batch_params.to_json, headers: auth_header
      }.to change(EmailMessage, :count).by(2)

      expect(response).to have_http_status(:ok)
      expect(json_body.dig("data", "accepted")).to eq(2)
    end
  end

  describe "POST /api/v1/emails/validate" do
    let(:valid_params) do
      {
        from: "sender@#{domain.domain}",
        to: ["user@example.com"],
        subject: "Validation Test",
        html: "<p>test</p>"
      }
    end

    it "returns valid for correct params" do
      post "/api/v1/emails/validate", params: valid_params.to_json, headers: auth_header

      expect(response).to have_http_status(:ok)
      expect(json_body.dig("data", "valid")).to be true
    end

    it "returns invalid for missing subject" do
      post "/api/v1/emails/validate", params: valid_params.except(:subject).to_json, headers: auth_header

      expect(response).to have_http_status(:ok)
      expect(json_body.dig("data", "valid")).to be false
    end
  end
end
