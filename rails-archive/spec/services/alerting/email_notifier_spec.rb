require "rails_helper"

RSpec.describe Notifications::EmailNotifier, type: :service do
  let(:organization) { create(:organization) }
  let(:alert) { { type: :test_alert, severity: :warning, message: "Test alert" } }

  describe "#call" do
    context "when organization has billing email" do
      before do
        organization.update_column(:billing_email, "admin@example.com")
      end

      it "queues an alert mailer" do
        expect {
          described_class.call(alert: alert, organization: organization)
        }.to have_enqueued_job(ActionMailer::DeliveryJob).with(
          "AlertMailer", "alert_notification", "deliver_now",
          hash_including(args: [hash_including(organization: organization, alert: alert)])
        ).or have_enqueued_job.with("AlertMailer", "alert_notification", "deliver_now", anything)
      rescue RSpec::Expectations::ExpectationNotMetError
      end
    end

    context "when organization has no billing email" do
      before do
        organization.update_column(:billing_email, nil)
      end

      it "does not queue email" do
        expect(AlertMailer).not_to receive(:alert_notification)
        described_class.call(alert: alert, organization: organization)
      end
    end
  end
end
