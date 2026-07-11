class AlertMailer < ApplicationMailer
  def alert_notification(organization:, alert:)
    @organization = organization
    @alert = alert
    @severity = alert[:severity].to_s.titleize
    @message = alert[:message]
    @value = alert[:value]
    @threshold = alert[:threshold]

    mail(
      to: organization.billing_email,
      subject: "[#{@severity}] Email Service Alert: #{@alert[:type].to_s.humanize}"
    )
  end
end
