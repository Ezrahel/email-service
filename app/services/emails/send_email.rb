module Emails
  class SendEmail < ApplicationService
    attr_reader :email

    def initialize(organization:, params:, idempotency_key: nil, api_key: nil)
      @organization = organization
      @params = params.with_indifferent_access
      @idempotency_key = idempotency_key
      @api_key = api_key
    end

    def call
      check_quota!
      check_idempotency! if @idempotency_key.present?

      validate_domain!(@params[:from])

      @email = nil

      ActiveRecord::Base.transaction do
        @email = create_email_message
        create_delivery_record
        record_usage
        record_audit_log
      end

      # Enqueue delivery (Phase 5)
      # EmailDispatcherWorker.perform_async(@email.id)

      self
    end

    private

    def create_email_message
      domain = extract_domain(@params[:from])

      @organization.email_messages.create!(
        batch_id: SecureRandom.uuid,
        from_address: @params[:from],
        to_address: @params[:to]&.first,
        recipient_type: "to",
        subject: @params[:subject],
        html_body: @params[:html],
        text_body: @params[:text],
        headers: @params[:headers] || {},
        tags: @params[:tags] || [],
        idempotency_key: @idempotency_key,
        reply_to: @params[:reply_to],
        scheduled_at: @params[:scheduled_at],
        status: scheduled? ? "queued" : "queued",
        domain_id: domain&.id
      )
    end

    def create_delivery_record
      @email.create_delivery!(
        organization: @organization,
        status: "pending",
        provider: "pending",
        max_attempts: 3
      )
    end

    def check_quota!
      return unless @organization.monthly_email_sent >= @organization.monthly_email_quota

      raise Errors::QuotaExceededError
    end

    def check_idempotency!
      existing = @organization.email_messages.find_by(idempotency_key: @idempotency_key)

      return unless existing

      raise Errors::IdempotencyError, "Email already sent with this idempotency key"
    end

    def validate_domain!(from_address)
      domain_name = from_address.to_s.split("@").last
      return unless domain_name

      domain = @organization.domains.verified.find_by(domain: domain_name)

      raise Errors::ValidationError, "Domain #{domain_name} is not verified" unless domain
    end

    def extract_domain(from_address)
      domain_name = from_address.to_s.split("@").last
      @organization.domains.verified.find_by(domain: domain_name)
    end

    def record_usage
      UsageRecord.create!(
        organization: @organization,
        metric: "email_sent",
        granularity: "hourly",
        bucket: Time.current.beginning_of_hour,
        count: 1,
        billable_count: 1
      )
    end

    def record_audit_log
      AuditLog.record!(
        action: "email.sent",
        resource_type: "EmailMessage",
        resource_id: @email.id,
        organization: @organization,
        api_key: @api_key,
        metadata: { to: @params[:to], subject: @params[:subject] }
      )
    end

    def scheduled?
      @params[:scheduled_at].present?
    end
  end
end
