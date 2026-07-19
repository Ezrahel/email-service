class ProviderConfig < ApplicationRecord
  # ── Associations ──────────────────────────────────────────────
  belongs_to :organization
  has_many :deliveries

  # ── Validations ───────────────────────────────────────────────
  validates :name, presence: true, length: { maximum: 255 }
  validates :provider_type, presence: true, inclusion: {
    in: %w[ses sendgrid mailgun postmark smtp]
  }
  validates :weight, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :priority, numericality: { only_integer: true }
  validates :health_score, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  # ── Scopes ────────────────────────────────────────────────────
  scope :active, -> { where(is_active: true, status: "active", deleted_at: nil) }
  scope :healthy, -> { active.where("health_score > ?", 50) }
  scope :by_priority, -> { order(priority: :asc, weight: :desc) }
  scope :primaries, -> { where(is_primary: true) }

  # ── Provider Adapter ──────────────────────────────────────────
  def adapter
    @adapter ||= Providers::AdapterRegistry.get(provider_type).new(self)
  end

  def test_connection!
    result = adapter.test
    update!(
      last_health_check_at: Time.current,
      health_score: result[:healthy] ? 100.0 : [health_score - 10, 0].max
    )
    result
  rescue StandardError => e
    update!(last_health_check_at: Time.current, health_score: [health_score - 20, 0].max)
    { healthy: false, error: e.message }
  end

  def update_health!(success:)
    new_score = if success
      [health_score + 5, 100.0].min
    else
      [health_score - 15, 0.0].max
    end
    update!(health_score: new_score, last_health_check_at: Time.current)
    update!(is_active: false, status: "degraded") if health_score < 20
  end

  # ── Soft Delete ───────────────────────────────────────────────
  def soft_delete
    update!(deleted_at: Time.current, is_active: false)
  end
end
