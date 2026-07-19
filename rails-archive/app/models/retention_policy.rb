class RetentionPolicy < ApplicationRecord
  belongs_to :organization, optional: true

  validates :table_name, presence: true
  validates :retention_days, presence: true, numericality: { greater_than: 0 }

  scope :enabled, -> { where(enabled: true) }
  scope :global, -> { where(organization_id: nil) }

  def self.retention_for(table_name, organization: nil)
    scope = where(table_name: table_name)
    scope = scope.where(organization_id: [nil, organization&.id].compact)
    scope.order(Arel.sql("CASE WHEN organization_id IS NOT NULL THEN 0 ELSE 1 END")).first
  end
end
