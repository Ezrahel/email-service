class Organization < ApplicationRecord
  # ── Associations ──────────────────────────────────────────────
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_many :teams, dependent: :destroy
  has_many :api_keys, dependent: :destroy
  has_many :domains, dependent: :destroy
  has_many :templates, dependent: :destroy
  has_many :email_messages, dependent: :destroy
  has_many :deliveries, dependent: :destroy
  has_many :webhooks, dependent: :destroy
  has_many :usage_records, dependent: :destroy
  has_many :audit_logs, dependent: :destroy
  has_many :provider_configs, dependent: :destroy

  # ── Validations ───────────────────────────────────────────────
  validates :name, presence: true, length: { maximum: 255 }
  validates :slug, presence: true, uniqueness: { conditions: -> { where(deleted_at: nil) } },
            format: { with: /\A[a-z0-9\-]+\z/, message: "only lowercase alphanumeric and hyphens" }
  validates :plan, presence: true, inclusion: { in: %w[free starter growth enterprise] }
  validates :status, presence: true, inclusion: { in: %w[active suspended trialing canceled] }
  validates :monthly_email_quota, numericality: { greater_than: 0 }

  # ── Scopes ────────────────────────────────────────────────────
  scope :active, -> { where(status: "active", deleted_at: nil) }
  scope :over_quota, -> { where("monthly_email_sent >= monthly_email_quota") }

  # ── Soft Delete ───────────────────────────────────────────────
  def soft_delete
    update!(deleted_at: Time.current, status: "canceled")
  end

  def ip_allowed?(ip)
    return true unless ip_allowlist_enabled?
    return false if ip_allowlist.blank?
    ip_allowlist.any? { |range| IPAddr.new(range).include?(ip) }
  rescue IPAddr::InvalidAddressError
    false
  end
end
