class ProviderAttempt < ApplicationRecord
  # ── Associations ──────────────────────────────────────────────
  belongs_to :delivery
  belongs_to :organization

  # ── Validations ───────────────────────────────────────────────
  validates :attempt_number, presence: true, numericality: { greater_than: 0 }
  validates :provider, presence: true
  validates :status, presence: true, inclusion: { in: %w[pending success failed aborted] }

  # ── Scopes ────────────────────────────────────────────────────
  scope :successful, -> { where(status: "success") }
  scope :failed, -> { where(status: "failed") }
  scope :chronological, -> { order(attempt_number: :asc) }
end
