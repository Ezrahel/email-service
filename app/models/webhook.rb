class Webhook < ApplicationRecord
  # ── Associations ──────────────────────────────────────────────
  belongs_to :organization
  has_many :webhook_deliveries, dependent: :destroy

  # ── Validations ───────────────────────────────────────────────
  validates :name, presence: true, length: { maximum: 255 }
  validates :url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp }
  validates :events, presence: true
  validates :secret, presence: true
  validates :status, inclusion: { in: %w[active paused disabled] }

  # ── Scopes ────────────────────────────────────────────────────
  scope :active, -> { where(is_active: true, status: "active", deleted_at: nil) }
  scope :for_event, ->(event_type) { active.where("events @> ?", [event_type].to_json) }

  # ── Signature ─────────────────────────────────────────────────
  def compute_signature(payload)
    OpenSSL::HMAC.hexdigest("SHA256", secret, payload.to_json)
  end

  def verify_signature(payload, signature)
    secure_compare(compute_signature(payload), signature)
  end

  # ── Soft Delete ───────────────────────────────────────────────
  def soft_delete
    update!(deleted_at: Time.current, is_active: false)
  end

  private

  def secure_compare(a, b)
    ActiveSupport::SecurityUtils.secure_compare(a.to_s, b.to_s)
  end
end
