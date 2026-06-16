class CreateDomainForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :domain, :string
  attribute :region, :string, default: "us"
  attribute :tracking_subdomain, :string, default: "track"
  attribute :organization

  validates :domain, presence: true,
    format: { with: /\A[a-z0-9]([a-z0-9\-]*[a-z0-9])?(\.[a-z0-9]([a-z0-9\-]*[a-z0-9])?)+\z/ }
  validates :region, inclusion: { in: %w[us eu ap] }
  validates :domain, uniqueness: {
    scope: :organization_id,
    conditions: -> { where(deleted_at: nil) }
  }

  def attributes
    super.except("organization")
  end

  def organization_id
    organization&.id
  end
end
