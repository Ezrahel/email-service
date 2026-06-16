class Team < ApplicationRecord
  # ── Associations ──────────────────────────────────────────────
  belongs_to :organization
  has_many :team_memberships, dependent: :destroy
  has_many :users, through: :team_memberships

  # ── Validations ───────────────────────────────────────────────
  validates :name, presence: true, length: { maximum: 255 }
  validates :slug, uniqueness: { scope: :organization_id,
            conditions: -> { where(deleted_at: nil) } }

  # ── Scopes ────────────────────────────────────────────────────
  scope :active, -> { where(deleted_at: nil) }

  # ── Soft Delete ───────────────────────────────────────────────
  def soft_delete
    update!(deleted_at: Time.current)
  end
end
