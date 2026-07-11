class ProviderCost < ApplicationRecord
  belongs_to :organization

  validates :organization_id, presence: true
  validates :provider, presence: true
  validates :date, presence: true
  validates :provider, uniqueness: { scope: %i[organization_id date] }
  validates :emails_sent, numericality: { greater_than_or_equal_to: 0 }
  validates :cost_cents, numericality: { greater_than_or_equal_to: 0 }

  scope :for_organization, ->(org) { where(organization_id: org) }
  scope :for_provider, ->(provider) { where(provider: provider) }
  scope :in_range, ->(from, to) { where(date: from..to) }
  scope :chronological, -> { order(date: :asc) }

  def cost_dollars
    cost_cents.to_f / 100
  end
end
