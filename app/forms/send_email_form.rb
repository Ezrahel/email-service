class SendEmailForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :from, :string
  attribute :to, array: true, default: []
  attribute :cc, array: true, default: []
  attribute :bcc, array: true, default: []
  attribute :subject, :string
  attribute :html, :string
  attribute :text, :string
  attribute :reply_to, :string
  attribute :headers, default: {}
  attribute :tags, default: []
  attribute :scheduled_at, :string
  attribute :organization

  validates :from, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :to, presence: true, length: { minimum: 1, maximum: 50 }
  validates :subject, presence: true, length: { maximum: 998 }
  validate :at_least_one_content_type
  validate :valid_recipients
  validate :validate_scheduled_at
  validate :validate_from_domain

  def attributes
    super.except("organization")
  end

  private

  def at_least_one_content_type
    return if html.present? || text.present?

    errors.add(:base, "Provide at least html or text content")
  end

  def valid_recipients
    %w[to cc bcc].each do |field|
      items = send(field)
      next unless items.is_a?(Array)

      items.each do |email|
        next if email.to_s.match?(URI::MailTo::EMAIL_REGEXP)

        errors.add(field.to_sym, "contains invalid email: #{email}")
      end
    end
  end

  def validate_scheduled_at
    return if scheduled_at.blank?

    Time.parse(scheduled_at)
  rescue ArgumentError, TypeError
    errors.add(:scheduled_at, "is not a valid datetime")
  end

  def validate_from_domain
    return if from.blank?
    return unless organization

    domain_name = from.split("@").last
    return unless domain_name
    return if organization.domains.verified.exists?(domain: domain_name)

    errors.add(:from, "domain #{domain_name} is not verified for this organization")
  end
end
