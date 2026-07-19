class Attachment < ApplicationRecord
  # ── Associations ──────────────────────────────────────────────
  belongs_to :email_message

  # ── Validations ───────────────────────────────────────────────
  validates :filename, presence: true, length: { maximum: 255 }
  validates :content_type, presence: true
  validates :byte_size, presence: true, numericality: { less_than_or_equal_to: 25.megabytes }
  validates :s3_key, presence: true, uniqueness: true

  # ── Soft Delete ───────────────────────────────────────────────
  def soft_delete
    update!(deleted_at: Time.current)
  end
end
