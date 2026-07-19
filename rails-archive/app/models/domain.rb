class Domain < ApplicationRecord
  # ── Associations ──────────────────────────────────────────────
  belongs_to :organization
  has_many :dns_records, dependent: :destroy
  has_many :email_messages

  # ── Validations ───────────────────────────────────────────────
  validates :domain, presence: true, uniqueness: { scope: :organization_id,
            conditions: -> { where(deleted_at: nil) } }
  validates :status, presence: true, inclusion: { in: %w[pending verifying verified failed] }
  validates :region, inclusion: { in: %w[us eu ap] }

  # ── Scopes ────────────────────────────────────────────────────
  scope :verified, -> { where(is_verified: true, deleted_at: nil) }
  scope :pending, -> { where(status: "pending", deleted_at: nil) }

  # ── DNS Records Generation ────────────────────────────────────
  def generate_dns_records!
    records = []

    # SPF
    spf = "v=spf1 include:mail.#{domain} ~all"
    records << dns_records.create!(
      record_type: "TXT",
      name: domain,
      value: spf,
      expected_value: spf
    )

    # DKIM
    dkim = "v=DKIM1; k=rsa; p=#{dkim_public_key}"
    records << dns_records.create!(
      record_type: "TXT",
      name: "#{dkim_selector}._domainkey.#{domain}",
      value: dkim,
      expected_value: dkim
    )

    # DMARC
    dmarc = "v=DMARC1; p=none; rua=mailto:dmarc@#{domain}"
    records << dns_records.create!(
      record_type: "TXT",
      name: "_dmarc.#{domain}",
      value: dmarc,
      expected_value: dmarc
    )

    # MX (bounce handling)
    mx = "10 mail.#{domain}"
    records << dns_records.create!(
      record_type: "MX",
      name: domain,
      value: mx,
      expected_value: mx
    )

    records
  end

  # ── Soft Delete ───────────────────────────────────────────────
  def soft_delete
    update!(deleted_at: Time.current)
  end
end
