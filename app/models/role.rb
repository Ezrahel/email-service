class Role < ApplicationRecord
  # ── Associations ──────────────────────────────────────────────
  has_many :memberships, dependent: :restrict_with_error

  # ── Validations ───────────────────────────────────────────────
  validates :name, presence: true, length: { maximum: 100 }
  validates :slug, presence: true, uniqueness: true,
            format: { with: /\A[a-z_]+\z/ }

  # ── Constants ─────────────────────────────────────────────────
  DEFAULT_ROLES = {
    owner: { name: "Owner", permissions: { manage_organization: true, manage_billing: true,
             manage_members: true, manage_api_keys: true, send_emails: true, read_analytics: true } },
    admin: { name: "Admin", permissions: { manage_members: true, manage_api_keys: true,
             send_emails: true, read_analytics: true, manage_templates: true } },
    developer: { name: "Developer", permissions: { send_emails: true, read_analytics: true,
                manage_templates: true, manage_webhooks: true } },
    read_only: { name: "Read Only", permissions: { read_analytics: true } }
  }.freeze
end
