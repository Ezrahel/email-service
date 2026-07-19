class ApiKey < ApplicationRecord
  # ── Associations ──────────────────────────────────────────────
  belongs_to :organization
  belongs_to :user, optional: true

  # ── Validations ───────────────────────────────────────────────
  validates :name, presence: true, length: { maximum: 255 }
  validates :key_digest, presence: true, uniqueness: true
  validates :key_prefix, presence: true
  validates :status, presence: true, inclusion: { in: %w[active revoked expired] }

  # ── Scopes ────────────────────────────────────────────────────
  scope :active, -> { where(status: "active", revoked_at: nil, deleted_at: nil) }
  scope :expired, -> { where("expires_at < ?", Time.current) }

  # ── Key Generation ────────────────────────────────────────────
  def self.generate_prefix
    "em_#{SecureRandom.hex(4)}"
  end

  def self.generate_full_key
    "#{generate_prefix}_#{SecureRandom.hex(24)}"
  end

  def self.create_with_key!(attrs)
    full_key = generate_full_key
    prefix = full_key[0, 11]

    create!(attrs.merge(
      key_prefix: prefix,
      key_digest: Digest::SHA256.hexdigest(full_key),
      key_last_chars: full_key.last(4)
    ))

    full_key
  end

  def revoke!
    update!(status: "revoked", revoked_at: Time.current)
  end

  def expired?
    expires_at.present? && expires_at < Time.current
  end
end
