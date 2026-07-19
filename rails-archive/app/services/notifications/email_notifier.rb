module Notifications
  class EmailNotifier < ApplicationService
    def initialize(alert:, organization:)
      @alert = alert
      @organization = organization
    end

    def call
      return unless @organization.billing_email.present?

      AlertMailer.alert_notification(
        organization: @organization,
        alert: @alert
      ).deliver_later if defined?(AlertMailer)
    end
  end
end
