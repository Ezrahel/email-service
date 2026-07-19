class Template < ApplicationRecord
  # ── Associations ──────────────────────────────────────────────
  belongs_to :organization
  has_many :versions, class_name: "TemplateVersion", dependent: :destroy
  has_many :email_messages

  # ── Validations ───────────────────────────────────────────────
  validates :name, presence: true, length: { maximum: 255 }
  validates :slug, uniqueness: { scope: :organization_id,
            conditions: -> { where(deleted_at: nil) } }
  validates :subject, presence: true
  validates :variables, exclusion: { in: [nil] }

  # ── Scopes ────────────────────────────────────────────────────
  scope :active, -> { where(is_active: true, deleted_at: nil) }

  # ── Rendering ─────────────────────────────────────────────────
  def render(variables = {})
    engine = Email::TemplateEngine.new
    {
      subject: engine.render(subject, variables),
      html: html_body ? engine.render(html_body, variables) : nil,
      text: text_body ? engine.render(text_body, variables) : nil
    }
  end

  # ── Versioning ────────────────────────────────────────────────
  def create_version!(user: nil, change_notes: nil)
    versions.create!(
      version: version_count + 1,
      subject: subject,
      html_body: html_body,
      text_body: text_body,
      variables: variables,
      created_by: user,
      change_notes: change_notes
    )
    increment!(:version_count)
  end

  # ── Soft Delete ───────────────────────────────────────────────
  def soft_delete
    update!(deleted_at: Time.current, is_active: false)
  end
end
