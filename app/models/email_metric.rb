class EmailMetric < ApplicationRecord
  # ── Associations ──────────────────────────────────────────────
  belongs_to :organization
  belongs_to :email_message
  belongs_to :delivery, optional: true

  # ── Validations ───────────────────────────────────────────────
  validates :email_message_id, uniqueness: true

  # ── Scopes ────────────────────────────────────────────────────
  scope :delivered, -> { where(is_delivered: true) }
  scope :opened, -> { where(is_opened: true) }
  scope :clicked, -> { where(is_clicked: true) }
  scope :bounced, -> { where(is_bounced: true) }

  # ── Aggregation ───────────────────────────────────────────────
  def self.aggregate_for(organization, granularity:, from: 30.days.ago, to: Time.current)
    bucket_expr = case granularity
    when "hourly" then "date_trunc('hour', created_at)"
    when "daily" then "date_trunc('day', created_at)"
    when "monthly" then "date_trunc('month', created_at)"
    end

    where(organization: organization)
      .where(created_at: from..to)
      .group(bucket_expr)
      .select(
        "#{bucket_expr} AS bucket",
        "COUNT(*) AS total",
        "COUNT(*) FILTER (WHERE is_delivered) AS delivered",
        "COUNT(*) FILTER (WHERE is_opened) AS opened",
        "COUNT(*) FILTER (WHERE is_clicked) AS clicked",
        "COUNT(*) FILTER (WHERE is_bounced) AS bounced",
        "COUNT(*) FILTER (WHERE is_complained) AS complained",
        "AVG(delivery_latency_ms) AS avg_latency"
      )
      .order("bucket ASC")
  end
end
