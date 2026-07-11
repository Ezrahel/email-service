class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("DEFAULT_FROM_EMAIL", "alerts@email-service.dev")
  layout "mailer"
end
