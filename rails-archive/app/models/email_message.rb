class EmailMessage < ApplicationRecord
  # ── Associations ──────────────────────────────────────────────
  belongs_to :organization
  belongs_to :template, optional: true
  belongs_to :domain, optional: true
  has_many :attachments, dependent: :destroy
  has_one :delivery, dependent: :destroy
  has_one :email_metric, dependent: :destroy

  # ── Validations ───────────────────────────────────────────────
  validates :from_address, presence: true,
            format: { with: URI::MailTo::EMAIL_REGEXP, message: "invalid from address" }
  validates :to_address, presence: true,
            format: { with: URI::MailTo::EMAIL_REGEXP, message: "invalid to address" }
  validates :subject, presence: true, length: { maximum: 998 }
  validates :status, presence: true, inclusion: {
    in: %w[queued sending delivered failed bounced opened clicked cancelled]
  }
  validates :recipient_type, inclusion: { in: %w[to cc bcc] }
  validates :retry_count, numericality: { greater_than_or_equal_to: 0 }
  validates :max_retries, numericality: { greater_than: 0 }
  validates :idempotency_key, uniqueness: { scope: :organization_id,
            allow_nil: true, message: "has already been used" }

  # ── Scopes ────────────────────────────────────────────────────
  scope :by_status, ->(status) { where(status: status) }
  scope :queued, -> { where(status: "queued") }
  scope :sending, -> { where(status: "sending") }
  scope :delivered, -> { where(status: "delivered") }
  scope :failed, -> { where(status: "failed") }
  scope :bounced, -> { where(status: "bounced") }
  scope :scheduled, -> { where("scheduled_at > ?", Time.current) }
  scope :ready_to_send, -> {
    where(status: %w[queued failed], scheduled_at: nil)
      .or(where(status: "queued").where("scheduled_at <= ?", Time.current))
  }
  scope :recent, -> { order(created_at: :desc).limit(50) }
  scope :since, ->(time) { where("created_at >= ?", time) }

  # ── Status Helpers ────────────────────────────────────────────
  def deliverable?
    %w[queued failed].include?(status) && retry_count < max_retries
  end

  def mark_sending!
    update!(status: "sending")
  end

  def mark_delivered!(timestamp: Time.current)
    update!(status: "delivered", delivered_at: timestamp)
  end

  def mark_failed!(reason:, code: nil)
    update!(status: "failed", failure_reason: reason, failure_code: code, failed_at: Time.current)
  end

  def mark_bounced!(reason:, classification: nil)
    update!(status: "bounced", failure_reason: reason, failure_code: classification, failed_at: Time.current)
  end

  def retryable?
    retry_count < max_retries &&
      %w[queued failed].include?(status)
  end

  def record_retry!
    increment!(:retry_count)
    update!(last_retry_at: Time.current)
  end

  def cancel!
    update!(status: "cancelled")
  end
end
