module Templates
  class SendTemplate < ApplicationService
    attr_reader :email

    def initialize(organization:, template:, params:)
      @organization = organization
      @template = template
      @params = params.with_indifferent_access
    end

    def call
      rendered = @template.render(@params[:variables] || {})

      email_params = {
        from: @params[:from] || @template.subject,
        to: @params[:to],
        cc: @params[:cc],
        bcc: @params[:bcc],
        subject: rendered[:subject],
        html: rendered[:html],
        text: rendered[:text],
        headers: {},
        tags: [{ name: "template", value: @template.slug }]
      }

      result = Emails::SendEmail.call(
        organization: @organization,
        params: email_params
      )

      @email = result.email
      @email.update!(template: @template)

      self
    end
  end
end
