class CreateWebhookForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :name, :string
  attribute :url, :string
  attribute :events, default: []
  attribute :api_version, :string, default: "v1"
  attribute :is_active, :boolean, default: true
  attribute :organization

  VALID_EVENTS = %w[
    email.sent email.delivered email.opened email.clicked
    email.failed email.bounced email.complained
  ].freeze

  validates :name, presence: true, length: { maximum: 255 }
  validates :url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp }
  validates :events, presence: true
  validate :valid_events

  def attributes
    super.except("organization")
  end

  private

  def valid_events
    return unless events.is_a?(Array)

    invalid = events - VALID_EVENTS
    errors.add(:events, "contains invalid events: #{invalid.join(', ')}") if invalid.any?
  end
end
