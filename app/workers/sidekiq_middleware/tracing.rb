module SidekiqMiddleware
  class Tracing
    def call(worker, job, queue)
      # OpenTelemetry span propagation
      if defined?(OpenTelemetry) && OpenTelemetry.tracer_provider
        tracer = OpenTelemetry.tracer_provider.tracer("email-service")
        span_name = "#{queue}.#{worker.class.name}"

        attributes = {
          "messaging.system" => "sidekiq",
          "messaging.destination" => queue,
          "messaging.operation" => "process",
          "sidekiq.job.class" => worker.class.name,
          "sidekiq.job.jid" => job["jid"],
          "sidekiq.queue" => queue
        }

        ctx = extract_context(job)
        tracer.in_span(span_name, attributes: attributes, with_parent: ctx) do |span|
          begin
            yield
            span.set_status(OpenTelemetry::SDK::Trace::Status.ok)
          rescue StandardError => e
            span.set_status(OpenTelemetry::SDK::Trace::Status.error(e.message))
            span.record_exception(e)
            raise
          end
        end
      else
        yield
      end
    end

    private

    def extract_context(job)
      return OpenTelemetry::Context.current unless job["trace_context"]

      OpenTelemetry.propagation.extract(
        Marshal.load(Base64.decode64(job["trace_context"]))
      )
    rescue StandardError
      OpenTelemetry::Context.current
    end
  end
end
