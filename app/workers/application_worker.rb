class ApplicationWorker
  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker

  sidekiq_options retry: 3, backtrace: 5

  sidekiq_throttle(
    threshold: { limit: 100, period: 1.second }
  )

  def self.inherited(subclass)
    super
    subclass.sidekiq_options backtrace: 5
  end

  def logger
    self.class.logger
  end

  def self.logger
    Sidekiq.logger
  end

  private

  def with_tracing(worker_class, email_id)
    tags = { worker: worker_class, email_id: email_id }
    Rails.logger.tagged(tags) { yield }
  end
end
