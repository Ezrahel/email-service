class Membership < ApplicationRecord
  # ── Associations ──────────────────────────────────────────────
  belongs_to :organization
  belongs_to :user
  belongs_to :role

  # ── Validations ───────────────────────────────────────────────
  validates :status, presence: true, inclusion: { in: %w[active invited inactive] }
  validates :user_id, uniqueness: { scope: :organization_id,
            message: "already a member of this organization",
            conditions: -> { where(deleted_at: nil, status: "active") } }

  # ── Scopes ────────────────────────────────────────────────────
  scope :active, -> { where(status: "active", deleted_at: nil) }
  scope :pending, -> { where(status: "invited") }

  # ── Soft Delete ───────────────────────────────────────────────
  def soft_delete
    update!(deleted_at: Time.current, status: "inactive")
  end
end
