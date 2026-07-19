class Delivery < ApplicationRecord
  # ── Associations ──────────────────────────────────────────────
  belongs_to :email_message
  belongs_to :organization
  belongs_to :provider_config, optional: true
  has_many :provider_attempts, dependent: :destroy
  has_many :delivery_events, dependent: :destroy
  has_one :email_metric, dependent: :destroy

  # ── Validations ───────────────────────────────────────────────
  validates :status, presence: true, inclusion: {
    in: %w[pending sending delivered failed bounced complained opened clicked]
  }
  validates :provider, presence: true
  validates :attempt_count, numericality: { greater_than_or_equal_to: 0 }
  validates :max_attempts, numericality: { greater_than: 0 }

  # ── Scopes ────────────────────────────────────────────────────
  scope :pending, -> { where(status: "pending") }
  scope :delivered, -> { where(status: "delivered") }
  scope :failed, -> { where(status: "failed") }
  scope :bounced, -> { where(status: "bounced") }
  scope :recent, -> { order(created_at: :desc) }

  # ── Status Transitions ────────────────────────────────────────
  def record_event!(event_type:, provider:, metadata: {}, timestamp: Time.current)
    delivery_events.create!(
      organization: organization,
      email_message: email_message,
      event_type: event_type,
      provider: provider,
      metadata: metadata,
      event_timestamp: timestamp
    )
  end

  def record_attempt!(provider:, success:, duration_ms: nil, response: {}, error: nil)
    provider_attempts.create!(
      organization: organization,
      attempt_number: attempt_count + 1,
      provider: provider,
      status: success ? "success" : "failed",
      duration_ms: duration_ms,
      http_status: response[:http_status],
      provider_message_id: response[:message_id],
      response_body: response[:body]&.to_json,
      error_message: error&.message,
      error_class: error&.class&.name,
      retryable: error.nil? || !error.is_a?(FinalProviderError)
    )

    increment!(:attempt_count)
    update!(last_attempt_at: Time.current, last_attempt_duration_ms: duration_ms, provider_message_id: response[:message_id])
  end

  def mark_delivered!(timestamp: Time.current)
    update!(status: "delivered", delivered_at: timestamp)
  end

  def mark_bounced!(type:, classification: nil)
    update!(status: "bounced", bounce_type: type, bounce_classification: classification, bounced_at: Time.current)
  end

  def mark_complaint!
    update!(status: "complained", complaint_at: Time.current)
  end

  def mark_failed!(reason:)
    update!(status: "failed", failure_reason: reason)
  end

  def retryable?
    attempt_count < max_attempts && status != "delivered"
  end
end
