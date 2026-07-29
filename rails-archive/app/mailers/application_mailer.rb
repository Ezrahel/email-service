class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("DEFAULT_FROM_EMAIL", "alerts@resendbyte.dev")
  layout "mailer"
end
