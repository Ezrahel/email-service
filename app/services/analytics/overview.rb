module Analytics
  class Overview < ApplicationService
    def initialize(organization:, since:, until:)
      @organization = organization
      @since = since
      @until = until
    end

    def call
      messages = @organization.email_messages
        .where(created_at: @since..@until)

      {
        period: { since: @since, until: @until },
        total_sent: messages.count,
        delivered: messages.where(status: "delivered").count,
        failed: messages.where(status: "failed").count,
        bounced: messages.where(status: "bounced").count,
        opened: messages.joins(:delivery).where(deliveries: { open_count: 1.. }).count,
        clicked: messages.joins(:delivery).where(deliveries: { click_count: 1.. }).count,
        delivery_rate: calculate_rate(messages.where(status: "delivered").count, messages.count),
        open_rate: calculate_rate(
          messages.joins(:delivery).where(deliveries: { open_count: 1.. }).count,
          messages.where(status: "delivered").count
        ),
        click_rate: calculate_rate(
          messages.joins(:delivery).where(deliveries: { click_count: 1.. }).count,
          messages.joins(:delivery).where(deliveries: { open_count: 1.. }).count
        ),
        bounce_rate: calculate_rate(messages.where(status: "bounced").count, messages.count)
      }
    end

    private

    def calculate_rate(part, total)
      return 0.0 if total.zero?
      (part.to_f / total * 100).round(2)
    end
  end
end
