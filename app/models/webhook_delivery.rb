class WebhookDelivery < ApplicationRecord
  # ── Associations ──────────────────────────────────────────────
  belongs_to :webhook
  belongs_to :organization

  # ── Validations ───────────────────────────────────────────────
  validates :event_type, presence: true
  validates :event_id, presence: true
  validates :attempt, numericality: { greater_than: 0 }
  validates :status, presence: true, inclusion: {
    in: %w[pending delivering delivered failed]
  }

  # ── Scopes ────────────────────────────────────────────────────
  scope :pending, -> { where(status: "pending") }
  scope :failed, -> { where(status: "failed") }
  scope :recent, -> { order(created_at: :desc) }

  # ── Delivery ──────────────────────────────────────────────────
  def mark_delivered!(http_status:, duration_ms:, response_body:)
    update!(
      status: "delivered",
      http_status: http_status,
      duration_ms: duration_ms,
      response_body: response_body,
      delivered_at: Time.current
    )
  end

  def mark_failed!(error_message:, http_status: nil)
    update!(
      status: "failed",
      http_status: http_status,
      error_message: error_message
    )
  end

  def retryable?
    status == "failed" && attempt < webhook.retry_count
  end
end
