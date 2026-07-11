require "rails_helper"

RSpec.describe Dashboard::Activity, type: :service do
  let(:organization) { create(:organization) }
  let(:email_message) { create(:email_message, organization: organization) }
  let(:delivery) { create(:delivery, email_message: email_message) }

  before do
    create_list(:delivery_event, 5, organization: organization, delivery: delivery, email_message: email_message,
                event_type: "delivered", event_timestamp: 1.hour.ago)
    create_list(:delivery_event, 2, organization: organization, delivery: delivery, email_message: email_message,
                event_type: "opened", event_timestamp: 30.minutes.ago)
  end

  subject { described_class.call(organization: organization, since: 24.hours.ago, until_time: Time.current) }

  describe "#call" do
    it "returns events list" do
      expect(subject[:events]).to be_an(Array)
      expect(subject[:events].size).to be <= 7
    end

    it "serializes events with required keys" do
      if subject[:events].any?
        event = subject[:events].first
        expect(event).to have_key(:id)
        expect(event).to have_key(:type)
        expect(event).to have_key(:timestamp)
        expect(event).to have_key(:email_id)
      end
    end

    it "includes pagination metadata" do
      expect(subject[:pagination]).to have_key(:has_more)
      expect(subject[:pagination]).to have_key(:cursor)
      expect(subject[:pagination]).to have_key(:per_page)
    end

    context "with cursor pagination" do
      it "supports cursor parameter" do
        first_page = described_class.call(organization: organization, since: 24.hours.ago, until_time: Time.current, per_page: 3)
        if first_page[:pagination][:has_more]
          cursor = first_page[:pagination][:cursor]
          second_page = described_class.call(organization: organization, since: 24.hours.ago, until_time: Time.current, cursor: cursor, per_page: 3)
          expect(second_page[:events].size).to be > 0
          expect(second_page[:events].first[:id]).not_to eq(first_page[:events].last[:id])
        end
      end
    end
  end
end
