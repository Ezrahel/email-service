class CreateTemplateForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :name, :string
  attribute :slug, :string
  attribute :subject, :string
  attribute :html_body, :string
  attribute :text_body, :string
  attribute :description, :string
  attribute :variables, default: []
  attribute :organization

  validates :name, presence: true, length: { maximum: 255 }
  validates :slug, presence: true,
    format: { with: /\A[a-z0-9\-_]+\z/, message: "only lowercase alphanumeric, hyphens, underscores" }
  validates :subject, presence: true
  validate :variables_format

  def attributes
    super.except("organization")
  end

  private

  def variables_format
    return unless variables.is_a?(Array)

    variables.each_with_index do |v, i|
      unless v.is_a?(Hash) && v["name"].present?
        errors.add(:variables, "item #{i} must have a 'name'")
      end
    end
  end
end
