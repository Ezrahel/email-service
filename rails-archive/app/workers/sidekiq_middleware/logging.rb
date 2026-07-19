module SidekiqMiddleware
  class Logging
    def call(worker, job, queue)
      logger = Sidekiq.logger

      logger.info({
        event: "job_started",
        worker: worker.class.name,
        jid: job["jid"],
        queue: queue,
        args: sanitize_args(job["args"]),
        started_at: Time.current.iso8601
      }.to_json)

      start = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      yield

      duration = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - start) * 1000).round(2)

      logger.info({
        event: "job_completed",
        worker: worker.class.name,
        jid: job["jid"],
        queue: queue,
        duration_ms: duration,
        completed_at: Time.current.iso8601
      }.to_json)
    rescue StandardError => e
      duration = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - start) * 1000).round(2)

      logger.error({
        event: "job_failed",
        worker: worker.class.name,
        jid: job["jid"],
        queue: queue,
        duration_ms: duration,
        exception: e.class.name,
        error: e.message
      }.to_json)

      raise
    end

    private

    def sanitize_args(args)
      case args
      when Array then args.map { |a| sanitize_args(a) }
      when Hash then args.transform_values { |v| sensitive_key?(v) ? "[FILTERED]" : sanitize_args(v) }
      when String then args.length > 200 ? "#{args[0..200]}..." : args
      else args
      end
    end

    def sensitive_key?(key)
      %w[password secret token key authorization].include?(key.to_s.downcase)
    end
  end
end
