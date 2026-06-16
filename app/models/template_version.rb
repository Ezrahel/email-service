class TemplateVersion < ApplicationRecord
  # ── Associations ──────────────────────────────────────────────
  belongs_to :template
  belongs_to :created_by, class_name: "User", optional: true

  # ── Validations ───────────────────────────────────────────────
  validates :version, presence: true, numericality: { greater_than: 0 }
  validates :subject, presence: true
  validates :version, uniqueness: { scope: :template_id,
            conditions: -> { where(deleted_at: nil) } }

  # ── Scopes ────────────────────────────────────────────────────
  scope :active, -> { where(deleted_at: nil) }

  # ── Soft Delete ───────────────────────────────────────────────
  def soft_delete
    update!(deleted_at: Time.current)
  end
end
