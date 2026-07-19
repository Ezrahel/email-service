class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # ── UUID primary keys ──────────────────────────────────────
  before_create :set_uuid

  private

  def set_uuid
    self.id ||= SecureRandom.uuid
  end
end
