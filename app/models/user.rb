class User < ApplicationRecord
  # ── Associations ──────────────────────────────────────────────
  has_many :memberships, dependent: :destroy
  has_many :organizations, through: :memberships
  has_many :team_memberships, dependent: :destroy
  has_many :teams, through: :team_memberships
  has_many :api_keys, dependent: :destroy

  # ── Authentication ────────────────────────────────────────────
  has_secure_password

  # ── Validations ───────────────────────────────────────────────
  validates :email, presence: true,
            uniqueness: { conditions: -> { where(deleted_at: nil) } },
            format: { with: URI::MailTo::EMAIL_REGEXP },
            length: { maximum: 255 }
  validates :first_name, :last_name, length: { maximum: 255 }
  validates :status, presence: true, inclusion: { in: %w[active inactive locked] }

  # ── Scopes ────────────────────────────────────────────────────
  scope :active, -> { where(status: "active", deleted_at: nil) }
  scope :locked, -> { where(status: "locked") }

  # ── Soft Delete ───────────────────────────────────────────────
  def soft_delete
    update!(deleted_at: Time.current, status: "inactive")
  end

  # ── Display ───────────────────────────────────────────────────
  def full_name
    [first_name, last_name].compact.join(" ").presence || email
  end

  def record_login!(ip:)
    update!(last_login_at: Time.current, last_login_ip: ip, failed_login_attempts: 0)
  end

  def increment_failed_attempts!
    increment!(:failed_login_attempts)
    if failed_login_attempts >= 10
      update!(status: "locked", locked_at: Time.current)
    end
  end
end
