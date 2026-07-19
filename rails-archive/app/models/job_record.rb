class JobRecord < ApplicationRecord
  self.table_name = "jobs"

  # ── Validations ───────────────────────────────────────────────
  validates :job_type, presence: true
  validates :queue, presence: true
  validates :status, presence: true, inclusion: {
    in: %w[enqueued running completed failed dead scheduled]
  }
  validates :worker_class, presence: true
  validates :jid, uniqueness: { allow_nil: true }

  # ── Scopes ────────────────────────────────────────────────────
  scope :recent, -> { order(created_at: :desc) }
  scope :failed, -> { where(status: "failed") }
  scope :running, -> { where(status: "running") }
  scope :scheduled, -> { where(status: "scheduled") }

  # ── Status Transitions ────────────────────────────────────────
  def mark_running!
    update!(status: "running", started_at: Time.current)
  end

  def mark_completed!(result: {})
    update!(
      status: "completed",
      finished_at: Time.current,
      result: result,
      duration_ms: ((Time.current - started_at) * 1000).round if started_at
    )
  end

  def mark_failed!(error_class:, error_message:)
    update!(
      status: "failed",
      failed_at: Time.current,
      error_class: error_class,
      error_message: error_message
    )
  end
end
