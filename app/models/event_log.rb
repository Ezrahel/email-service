class EventLog < ApplicationRecord
  # ── Validations ───────────────────────────────────────────────
  validates :event_type, presence: true
  validates :payload, exclusion: { in: [nil] }
  validates :source, presence: true
  validates :event_timestamp, presence: true

  # ── Scopes ────────────────────────────────────────────────────
  scope :unprocessed, -> { where(processed_at: nil) }
  scope :by_type, ->(type) { where(event_type: type) }
  scope :since, ->(time) { where("event_timestamp >= ?", time) }
  scope :recent, -> { order(event_timestamp: :desc) }

  # ── Processing ────────────────────────────────────────────────
  def mark_processed!
    update!(processed_at: Time.current)
  end

  # ── Event Recording ───────────────────────────────────────────
  def self.record!(event_type:, organization:, payload: {}, source:, metadata: {}, resource: nil)
    create!(
      organization: organization,
      event_type: event_type,
      resource: resource,
      payload: payload,
      source: source,
      metadata: metadata,
      event_timestamp: Time.current
    )
  end
end
