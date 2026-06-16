module EmailPipeline
  class RecipientExpander < ApplicationService
    def initialize(email:)
      @email = email
    end

    def call
      # For now, each email_message already represents one (to) recipient.
      # CC and BCC stored as JSONB on the original API call.
      # This service can expand group aliases or list-based recipients.

      # Future: resolve mailing list aliases
      # Future: deduplicate across to/cc/bcc

      [@email.to_address]
    end
  end
end
