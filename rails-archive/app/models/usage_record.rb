class UsageRecord < ApplicationRecord
  # ── Associations ──────────────────────────────────────────────
  belongs_to :organization

  # ── Validations ───────────────────────────────────────────────
  validates :metric, presence: true
  validates :granularity, presence: true, inclusion: { in: %w[hourly daily monthly] }
  validates :bucket, presence: true
  validates :metric, uniqueness: { scope: %i[organization_id granularity bucket] }
  validates :count, numericality: { greater_than_or_equal_to: 0 }
  validates :billable_count, numericality: { greater_than_or_equal_to: 0 }

  # ── Scopes ────────────────────────────────────────────────────
  scope :for_organization, ->(org) { where(organization_id: org) }
  scope :for_metric, ->(metric) { where(metric: metric) }
  scope :for_granularity, ->(g) { where(granularity: g) }
  scope :in_range, ->(from, to) { where(bucket: from..to) }
  scope :chronological, -> { order(bucket: :asc) }

  # ── Aggregation ───────────────────────────────────────────────
  def self.aggregate_for(organization, metric:, from:, to:)
    where(organization: organization, metric: metric, bucket: from..to)
      .select(
        "SUM(count) AS total_count",
        "SUM(billable_count) AS total_billable",
        "SUM(cost) AS total_cost"
      )
  end
end
