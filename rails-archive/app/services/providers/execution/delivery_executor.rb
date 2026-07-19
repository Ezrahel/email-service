module Providers
  module Execution
    class DeliveryExecutor
      Result = Struct.new(:success?, :provider_response, :error, keyword_init: true)

      def initialize(delivery:)
        @delivery = delivery
        @email_message = delivery.email_message
        @organization = delivery.organization
      end

      def execute
        config = select_provider
        return fail_result("No provider available") unless config

        cb = Health::CircuitBreaker.new(config)
        return fail_result("Circuit breaker open for #{config.provider_type}") unless cb.allow_request?

        adapter = config.adapter
        response = adapter.send_email(@email_message)

        if response.success?
          cb.record_success
          record_success(config, response)
          Result.new(success?: true, provider_response: response)
        else
          cb.record_failure
          handle_failure(config, response)
        end
      end

      def execute_batch(email_messages)
        config = select_provider
        return fail_result("No provider available") unless config

        adapter = config.adapter
        unless adapter.supports_batch?
          return execute_sequential(email_messages)
        end

        response = adapter.send_batch(email_messages)

        if response.success?
          record_batch_success(config, response, email_messages)
          Result.new(success?: true, provider_response: response)
        else
          Result.new(success?: false, provider_response: response, error: response.error_message)
        end
      end

      def cancel(provider_message_id)
        config = select_provider
        return fail_result("No provider available") unless config

        adapter = config.adapter
        unless adapter.supports_cancel?
          return fail_result("#{config.provider_type} does not support cancellation")
        end

        response = adapter.cancel_delivery(provider_message_id)
        Result.new(success?: response.success?, provider_response: response)
      end

      def check_status(provider_message_id)
        config = select_provider
        return fail_result("No provider available") unless config

        adapter = config.adapter
        unless adapter.supports_status_check?
          return fail_result("#{config.provider_type} does not support status checks")
        end

        response = adapter.check_status(provider_message_id)
        Result.new(success?: response.success?, provider_response: response)
      end

      private

      def select_provider
        router = Routing::Router.new(
          organization: @organization,
          email: @email_message,
          mode: nil
        )
        router.select&.provider_config
      end

      def execute_sequential(email_messages)
        results = email_messages.map { |msg| self.class.new(delivery: @delivery).execute }
        all_success = results.all?(&:success?)
        Result.new(
          success?: all_success,
          provider_response: nil,
          error: all_success ? nil : "Some messages failed in batch"
        )
      end

      def record_success(config, response)
        @delivery.update!(
          status: "delivered",
          provider: config.provider_type,
          provider_message_id: response.provider_message_id,
          delivered_at: Time.current,
          provider_response: response.to_h
        )
        @email_message.mark_delivered!

        EventPublisher.publish(
          event_type: "email.delivered",
          organization_id: @organization.id,
          payload: {
            email_id: @email_message.id,
            delivery_id: @delivery.id,
            provider: config.provider_type,
            provider_message_id: response.provider_message_id,
            duration_ms: response.metadata[:duration_ms]
          }
        )
      end

      def record_batch_success(config, response, email_messages)
        @delivery.update!(
          status: "delivered",
          provider: config.provider_type,
          provider_message_id: response.provider_message_id,
          delivered_at: Time.current,
          provider_response: response.to_h
        )

        email_messages.each(&:mark_delivered!)

        EventPublisher.publish(
          event_type: "email.delivered",
          organization_id: @organization.id,
          payload: {
            email_id: email_messages.map(&:id).join(","),
            delivery_id: @delivery.id,
            provider: config.provider_type,
            batch: true,
            count: email_messages.size
          }
        )
      end

      def handle_failure(config, response)
        config.update_health!(success: false)

        if response.retryable_failure? && @delivery.retryable?
          @delivery.update!(
            status: "pending",
            last_retry_at: Time.current,
            failure_reason: response.error_message
          )

          delay = RetryPolicy.delay_for(@delivery.attempt_count + 1)
          EmailDispatchWorker.perform_in(delay.to_i, @delivery.id, config.provider_type)
        else
          @delivery.mark_failed!(reason: response.error_message)
          @email_message.mark_failed!(reason: response.error_message)

          EventPublisher.publish(
            event_type: "email.failed",
            organization_id: @organization.id,
            payload: {
              email_id: @email_message.id,
              delivery_id: @delivery.id,
              provider: config.provider_type,
              error: response.error_message,
              error_code: response.error_code
            }
          )
        end

        Result.new(
          success?: false,
          provider_response: response,
          error: response.error_message
        )
      end

      def fail_result(error)
        Result.new(success?: false, error: error)
      end
    end
  end
end
