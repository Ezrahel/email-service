class DnsRecord < ApplicationRecord
  # ── Associations ──────────────────────────────────────────────
  belongs_to :domain

  # ── Validations ───────────────────────────────────────────────
  validates :record_type, presence: true, inclusion: { in: %w[TXT MX CNAME AAAA] }
  validates :name, presence: true
  validates :value, presence: true
  validates :status, presence: true, inclusion: { in: %w[pending verified failed] }

  # ── Scopes ────────────────────────────────────────────────────
  scope :pending, -> { where(is_verified: false) }
  scope :verified, -> { where(is_verified: true) }

  # ── Verification ──────────────────────────────────────────────
  def verify!
    resolver = Resolv::DNS.new
    records = resolver.getresources(name, record_type_for_resolver)
    actual = records.map(&:to_s).join(", ")

    update!(
      last_checked_at: Time.current,
      actual_value: actual,
      is_verified: records.any? { |r| r.to_s.include?(expected_value.to_s.strip) },
      status: is_verified ? "verified" : "failed"
    )

    is_verified
  rescue StandardError => e
    update!(last_checked_at: Time.current, status: "failed")
    false
  end

  private

  def record_type_for_resolver
    case record_type
    when "TXT" then Resolv::DNS::Resource::IN::TXT
    when "MX" then Resolv::DNS::Resource::IN::MX
    when "CNAME" then Resolv::DNS::Resource::IN::CNAME
    when "AAAA" then Resolv::DNS::Resource::IN::AAAA
    end
  end
end
