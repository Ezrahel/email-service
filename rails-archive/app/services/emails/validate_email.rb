module Emails
  class ValidateEmail < ApplicationService
    def initialize(params:)
      @params = params.with_indifferent_access
    end

    def call
      errors = []

      errors << "Missing 'from' address" if @params[:from].blank?
      errors << "Missing 'to' recipients" if @params[:to].blank?
      errors << "Missing 'subject'" if @params[:subject].blank?
      errors << "Missing email content (html or text)" if @params[:html].blank? && @params[:text].blank?

      errors << "Invalid 'from' format" if @params[:from].present? && !valid_email?(@params[:from])
      errors << "Invalid 'to' format" if @params[:to].present? && @params[:to].any? { |e| !valid_email?(e) }

      errors
    end

    private

    def valid_email?(email)
      URI::MailTo::EMAIL_REGEXP.match?(email.to_s)
    end
  end
end
