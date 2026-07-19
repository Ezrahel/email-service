class TeamMembership < ApplicationRecord
  # ── Associations ──────────────────────────────────────────────
  belongs_to :team
  belongs_to :user

  # ── Validations ───────────────────────────────────────────────
  validates :user_id, uniqueness: { scope: :team_id,
            conditions: -> { where(deleted_at: nil) } }
  validates :role, inclusion: { in: %w[member admin maintainer] }

  # ── Scopes ────────────────────────────────────────────────────
  scope :active, -> { where(deleted_at: nil) }

  # ── Soft Delete ───────────────────────────────────────────────
  def soft_delete
    update!(deleted_at: Time.current)
  end
end
