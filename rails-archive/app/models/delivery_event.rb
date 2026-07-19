class DeliveryEvent < ApplicationRecord
  # ── Associations ──────────────────────────────────────────────
  belongs_to :delivery
  belongs_to :email_message
  belongs_to :organization

  # ── Validations ───────────────────────────────────────────────
  validates :event_type, presence: true, inclusion: {
    in: %w[sent delivered opened clicked failed bounced complained unsubscribed]
  }
  validates :provider, presence: true
  validates :event_timestamp, presence: true

  # ── Scopes ────────────────────────────────────────────────────
  scope :unprocessed, -> { where(processed_at: nil) }
  scope :since, ->(time) { where("event_timestamp >= ?", time) }
  scope :by_type, ->(type) { where(event_type: type) }
  scope :recent, -> { order(event_timestamp: :desc) }

  # ── Processing ────────────────────────────────────────────────
  def mark_processed!
    update!(processed_at: Time.current)
  end

  def self.event_types_for_webhook
    %w[sent delivered opened clicked failed bounced complained]
  end
end
