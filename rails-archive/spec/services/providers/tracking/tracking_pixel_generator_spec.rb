RSpec.describe Providers::Tracking::TrackingPixelGenerator do
  describe ".pixel_data" do
    it "returns a GIF" do
      expect(described_class.pixel_data).to start_with("GIF89a")
    end
  end

  describe ".content_type" do
    it { expect(described_class.content_type).to eq("image/gif") }
  end

  describe ".tracking_url" do
    it "generates a signed URL" do
      url = described_class.tracking_url(
        email_message_id: "abc-123",
        organization_id: "org-456",
        base_url: "https://t.example.com"
      )
      expect(url).to start_with("https://t.example.com/t/o/")
      expect(url).to end_with(".gif")
    end
  end

  describe ".verify_token" do
    it "verifies a valid token" do
      email_message = create(:email_message)
      token = described_class.send(:generate_token, email_message.id, email_message.organization_id)
      result = described_class.verify_token(token)
      expect(result).to eq(email_message)
    end

    it "returns nil for invalid token" do
      expect(described_class.verify_token("invalid")).to be_nil
    end
  end
end
