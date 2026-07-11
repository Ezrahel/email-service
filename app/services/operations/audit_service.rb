module Operations
  class AuditService < ApplicationService
    VALID_ACTIONS = %w[
      create update delete revoke verify
      send retry cancel pause resume
      webhook_delivery provider_switch
    ].freeze

    VALID_RESOURCES = %w[
      email_message domain template api_key webhook
      provider_config organization user team
      delivery email_metric usage_record
    ].freeze

    def initialize(
      action:, resource_type:, resource_id: nil,
      organization: nil, user: nil, api_key: nil,
      changes: {}, metadata: {}, ip_address: nil, user_agent: nil, request_id: nil
    )
      @action = action
      @resource_type = resource_type
      @resource_id = resource_id
      @organization = organization
      @user = user
      @api_key = api_key
      @changes = changes
      @metadata = metadata
      @ip_address = ip_address
      @user_agent = user_agent
      @request_id = request_id

      validate!
    end

    def call
      AuditLog.record!(
        action: @action,
        resource_type: @resource_type,
        resource_id: @resource_id,
        organization: @organization,
        user: @user,
        api_key: @api_key,
        changes: @changes,
        metadata: @metadata,
        ip_address: @ip_address,
        user_agent: @user_agent,
        request_id: @request_id
      )
    end

    def self.log_send(organization:, email:, api_key: nil)
      call(
        action: "send",
        resource_type: "email_message",
        resource_id: email.id,
        organization: organization,
        api_key: api_key,
        metadata: {
          from: email.from,
          to: email.to,
          subject: email.subject,
          template_id: email.template_id
        }
      )
    end

    def self.log_domain_change(organization:, domain:, action:, user: nil)
      call(
        action: action,
        resource_type: "domain",
        resource_id: domain.id,
        organization: organization,
        user: user,
        changes: domain.previous_changes,
        metadata: { domain: domain.domain }
      )
    end

    def self.log_api_key_action(organization:, api_key:, action:, user: nil)
      call(
        action: action,
        resource_type: "api_key",
        resource_id: api_key.id,
        organization: organization,
        user: user,
        metadata: { key_name: api_key.name, key_prefix: api_key.key&.first(8) }
      )
    end

    def self.log_provider_change(organization:, provider_config:, action:, user: nil)
      call(
        action: action,
        resource_type: "provider_config",
        resource_id: provider_config.id,
        organization: organization,
        user: user,
        changes: provider_config.previous_changes,
        metadata: { provider: provider_config.provider }
      )
    end

    def self.log_webhook_action(organization:, webhook:, action:, user: nil)
      call(
        action: action,
        resource_type: "webhook",
        resource_id: webhook.id,
        organization: organization,
        user: user,
        changes: webhook.previous_changes,
        metadata: { url: webhook.url, events: webhook.events }
      )
    end

    private

    def validate!
      raise ArgumentError, "Invalid action: #{@action}" unless VALID_ACTIONS.include?(@action)
      raise ArgumentError, "Invalid resource_type: #{@resource_type}" unless VALID_RESOURCES.include?(@resource_type)
    end
  end
end
