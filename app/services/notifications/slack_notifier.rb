module Notifications
  class SlackNotifier < ApplicationService
    def initialize(alert:, organization:)
      @alert = alert
      @organization = organization
    end

    def call
      return unless webhook_url

      payload = {
        text: "*[#{@alert[:severity].upcase}] #{@alert[:message]}*",
        attachments: [{
          color: color,
          fields: [
            { title: "Organization", value: @organization.name, short: true },
            { title: "Type", value: @alert[:type].to_s, short: true },
            { title: "Value", value: @alert[:value].to_s, short: true },
            { title: "Threshold", value: @alert[:threshold].to_s, short: true }
          ],
          ts: Time.current.to_i
        }]
      }

      HTTParty.post(webhook_url, body: payload.to_json, headers: { "Content-Type" => "application/json" })
    end

    private

    def webhook_url
      ENV["SLACK_WEBHOOK_URL"]
    end

    def color
      case @alert[:severity]
      when :critical then "danger"
      when :warning then "warning"
      else "good"
      end
    end
  end
end
