class AuditLog < ApplicationRecord
  # ── Associations ──────────────────────────────────────────────
  belongs_to :organization, optional: true
  belongs_to :user, optional: true
  belongs_to :api_key, optional: true

  # ── Validations ───────────────────────────────────────────────
  validates :action, presence: true
  validates :resource_type, presence: true
  validates :event_timestamp, presence: true

  # ── Scopes ────────────────────────────────────────────────────
  scope :recent, -> { order(event_timestamp: :desc) }
  scope :by_action, ->(action) { where(action: action) }
  scope :by_resource, ->(type, id = nil) {
    scope = where(resource_type: type)
    scope = scope.where(resource_id: id) if id
    scope
  }
  scope :since, ->(time) { where("event_timestamp >= ?", time) }

  # ── Recording ─────────────────────────────────────────────────
  def self.record!(
    action:, resource_type:, resource_id: nil,
    organization: nil, user: nil, api_key: nil,
    changes: {}, metadata: {}, ip_address: nil, user_agent: nil, request_id: nil
  )
    create!(
      organization: organization,
      user: user,
      api_key: api_key,
      action: action,
      resource_type: resource_type,
      resource_id: resource_id,
      changes: changes,
      metadata: metadata,
      ip_address: ip_address,
      user_agent: user_agent,
      request_id: request_id || Current.request_id,
      event_timestamp: Time.current
    )
  end
end
