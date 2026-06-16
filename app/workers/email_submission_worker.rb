class EmailSubmissionWorker < ApplicationWorker
  sidekiq_options queue: :emails, retry: 3

  def perform(email_id)
    email = EmailMessage.find_by(id: email_id)
    return unless email
    return unless email.deliverable?

    email.mark_sending!

    EmailPipeline::Orchestrator.call(email: email)

    EventPublisher.publish(
      event_type: "email.processing",
      organization_id: email.organization_id,
      payload: { email_id: email.id, subject: email.subject }
    )
  rescue ActiveRecord::RecordNotFound
    logger.warn "Email #{email_id} not found, skipping"
  rescue Errors::ApplicationError => e
    email&.mark_failed!(reason: e.message, code: e.code)
    raise
  end
end
