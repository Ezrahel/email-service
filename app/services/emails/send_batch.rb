module Emails
  class SendBatch < ApplicationService
    MAX_BATCH_SIZE = 1000

    attr_reader :batch_id, :total, :accepted, :rejected, :emails

    def initialize(organization:, messages:, api_key: nil)
      @organization = organization
      @messages = messages
      @api_key = api_key
      @batch_id = SecureRandom.uuid
      @total = messages.size
      @accepted = 0
      @rejected = 0
      @errors = []
    end

    def call
      raise Errors::ValidationError, "Batch too large (max #{MAX_BATCH_SIZE})" if @total > MAX_BATCH_SIZE

      @messages.each do |msg_params|
        process_message(msg_params)
      rescue Errors::ApplicationError => e
        @errors << { message: msg_params, error: e.message }
        @rejected += 1
      end

      self
    end

    private

    def process_message(msg_params)
      result = Emails::SendEmail.call(
        organization: @organization,
        params: msg_params,
        api_key: @api_key
      )

      @emails ||= []
      @emails << result.email
      @accepted += 1
    end
  end
end
