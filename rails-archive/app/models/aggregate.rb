class Aggregate < ApplicationRecord
  # ── Validations ───────────────────────────────────────────────
  validates :organization_id, presence: true
  validates :metric_name, presence: true
  validates :granularity, presence: true, inclusion: { in: %w[hourly daily monthly] }
  validates :bucket, presence: true
  validates :metric_name, uniqueness: { scope: %i[organization_id granularity bucket] }

  # ── Scopes ────────────────────────────────────────────────────
  scope :for_organization, ->(org) { where(organization_id: org) }
  scope :for_metric, ->(name) { where(metric_name: name) }
  scope :for_granularity, ->(g) { where(granularity: g) }
  scope :in_range, ->(from, to) { where(bucket: from..to) }
  scope :chronological, -> { order(bucket: :asc) }

  # ── Rate Calculations ─────────────────────────────────────────
  def delivery_rate
    return 0.0 if total_count.zero?
    (delivered_count.to_f / total_count * 100).round(2)
  end

  def open_rate
    return 0.0 if delivered_count.zero?
    (opened_count.to_f / delivered_count * 100).round(2)
  end

  def click_rate
    return 0.0 if opened_count.zero?
    (clicked_count.to_f / opened_count * 100).round(2)
  end

  def bounce_rate
    return 0.0 if total_count.zero?
    (bounced_count.to_f / total_count * 100).round(2)
  end

  def complaint_rate
    return 0.0 if total_count.zero?
    (complained_count.to_f / total_count * 100).round(4)
  end
end
