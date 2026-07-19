class ApplicationJob < ActiveJob::Base
  include Sidekiq::Status::Worker

  # Automatically retry jobs that encountered a deadlock
  retry_on ActiveRecord::Deadlocked, wait: :polynomially_longer, attempts: 3

  # Discard retry if the record is gone
  discard_on ActiveJob::DeserializationError

  around_perform do |job, block|
    Current.set(request_id: job.job_id) do
      Rails.logger.tagged(job.class.name, job.job_id) do
        block.call
      end
    end
  end
end
#end