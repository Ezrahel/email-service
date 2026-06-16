class DeliveryCoordinator
  Result = Struct.new(
    :success?, :provider, :provider_message_id, :duration_ms, :error,
    :delivery_status, :failover_scheduled?,
    keyword_init: true
  )

  def initialize(delivery:, provider_type: nil)
    @delivery = delivery
    @provider_type = provider_type
  end

  def dispatch!
    @delivery.with_lock do
      return Result.new(success?: false, error: "Not retryable", delivery_status: @delivery.status) unless @delivery.retryable?

      provider_config = find_provider_config
      unless provider_config
        @delivery.mark_failed!(reason: "No provider available")
        @delivery.email_message&.mark_failed!(reason: "No provider available")
        return Result.new(success?: false, error: "No provider available", delivery_status: "failed")
      end

      @delivery.update!(status: "sending", provider: provider_config.provider_type)
      @delivery.record_attempt!(provider: provider_config.provider_type, success: false)
      CircuitChecker.record_success(provider_config.provider_type, @delivery.organization_id)

      adapter = provider_config.adapter
      result = adapter.send_email(@delivery.email_message)

      if result.success?
        handle_success(provider_config, result)
      else
        handle_failure(provider_config, result)
      end
    end
  end

  private

  def find_provider_config
    if @provider_type
      @delivery.organization.provider_configs.active.healthy.find_by(provider_type: @provider_type)
    else
      ProviderRouter.select_provider(organization: @delivery.organization)&.provider_config
    end
  end

  def handle_success(provider_config, result)
    @delivery.update!(
      status: "delivered",
      provider_message_id: result.provider_message_id,
      delivered_at: Time.current
    )
    @delivery.email_message&.mark_delivered!

    EventPublisher.publish(
      event_type: "email.delivered",
      organization_id: @delivery.organization_id,
      payload: {
        email_id: @delivery.email_message_id,
        delivery_id: @delivery.id,
        provider: provider_config.provider_type,
        provider_message_id: result.provider_message_id,
        duration_ms: result.duration_ms
      }
    )

    Result.new(
      success?: true,
      provider: provider_config.provider_type,
      provider_message_id: result.provider_message_id,
      duration_ms: result.duration_ms,
      delivery_status: "delivered"
    )
  end

  def handle_failure(provider_config, result)
    provider_config.update_health!(success: false)
    CircuitChecker.record_failure(provider_config.provider_type, @delivery.organization_id)

    failover_config = ProviderRouter.select_failover(
      organization: @delivery.organization,
      failed_provider: provider_config.provider_type
    )&.provider_config

    if failover_config && @delivery.retryable?
      @delivery.update!(
        status: "pending",
        provider: failover_config.provider_type,
        last_retry_at: Time.current
      )

      EmailDispatchWorker.perform_in(5.seconds, @delivery.id, failover_config.provider_type)

      Rails.logger.info({
        event: "delivery_failover",
        delivery_id: @delivery.id,
        from: provider_config.provider_type,
        to: failover_config.provider_type,
        error: result.error
      }.to_json)

      Result.new(
        success?: true,
        provider: failover_config.provider_type,
        error: "Failover from #{provider_config.provider_type}: #{result.error}",
        delivery_status: "pending",
        failover_scheduled?: true
      )
    else
      @delivery.update!(
        status: "failed",
        failure_reason: result.error,
        failure_code: result.error_code
      )
      @delivery.email_message&.mark_failed!(reason: result.error)

      reason = if failover_config
        "All providers failed after failover: #{result.error}"
      else
        "No failover provider: #{result.error}"
      end

      EventPublisher.publish(
        event_type: "email.failed",
        organization_id: @delivery.organization_id,
        payload: {
          email_id: @delivery.email_message_id,
          delivery_id: @delivery.id,
          provider: provider_config.provider_type,
          error: reason
        }
      )

      if !@delivery.retryable?
        DeadLetterService.send(@delivery)
      end

      Result.new(
        success?: false,
        provider: provider_config.provider_type,
        error: reason,
        delivery_status: "failed"
      )
    end
  end
end
