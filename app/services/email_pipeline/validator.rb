module EmailPipeline
  class Validator < ApplicationService
    def initialize(email:)
      @email = email
    end

    def call
      errors = []

      errors << "Missing organization" unless @email.organization_id
      errors << "Invalid from address" unless valid_email?(@email.from_address)
      errors << "Invalid to address" unless valid_email?(@email.to_address)
      errors << "Subject is empty" if @email.subject.blank?
      errors << "No content (html or text)" if @email.html_body.blank? && @email.text_body.blank?
      errors << "Subject too long (#{@email.subject.length} > 998)" if @email.subject.length > 998
      errors << "Scheduled date is in the past" if @email.scheduled_at.present? && @email.scheduled_at < Time.current

      if errors.any?
        raise Errors::ValidationError, "Email validation failed: #{errors.join(', ')}"
      end

      true
    end

    private

    def valid_email?(address)
      URI::MailTo::EMAIL_REGEXP.match?(address.to_s)
    end
  end
end
