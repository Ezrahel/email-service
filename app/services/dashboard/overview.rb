module Dashboard
  class Overview < ApplicationService
    def initialize(organization:, since:, until_time:)
      @organization = organization
      @since = since
      @until = until_time
    end

    def call
      messages = @organization.email_messages.where(created_at: @since..@until)
      current_hour = @organization.email_messages.where("created_at > ?", 1.hour.ago)

      {
        period: { since: @since, until: @until },
        totals: {
          sent: messages.count,
          delivered: messages.where(status: "delivered").count,
          failed: messages.where(status: "failed").count,
          bounced: messages.where(status: "bounced").count,
          opened: messages.joins(:delivery).where(deliveries: { open_count: 1.. }).count,
          clicked: messages.joins(:delivery).where(deliveries: { click_count: 1.. }).count,
          complained: messages.joins(:delivery).where.not(deliveries: { complaint_at: nil }).count
        },
        rates: {
          delivery: rate(messages.where(status: "delivered").count, messages.count),
          open: rate(
            messages.joins(:delivery).where(deliveries: { open_count: 1.. }).count,
            messages.where(status: "delivered").count
          ),
          click: rate(
            messages.joins(:delivery).where(deliveries: { click_count: 1.. }).count,
            messages.joins(:delivery).where(deliveries: { open_count: 1.. }).count
          ),
          bounce: rate(messages.where(status: "bounced").count, messages.count),
          complaint: rate(
            messages.joins(:delivery).where.not(deliveries: { complaint_at: nil }).count,
            messages.count
          )
        },
        current_hour: {
          sent: current_hour.count,
          failed: current_hour.where(status: "failed").count
        },
        top_domains: top_domains(messages),
        trend: last_30_days_trend
      }
    end

    private

    def top_domains(messages)
      messages.joins(:domain)
        .group("domains.domain")
        .select("domains.domain", "COUNT(*) AS cnt")
        .order("cnt DESC")
        .limit(5)
        .map { |r| { domain: r.domain, count: r.cnt.to_i } }
    end

    def last_30_days_trend
      @organization.email_messages
        .where("created_at > ?", 30.days.ago)
        .group("date_trunc('day', created_at)")
        .select(
          "date_trunc('day', created_at) AS date",
          "COUNT(*) AS total",
          "COUNT(*) FILTER (WHERE status = 'delivered') AS delivered"
        )
        .order("date ASC")
        .map { |r| { date: r.date, total: r.total.to_i, delivered: r.delivered.to_i } }
    end

    def rate(part, total)
      return 0.0 if total.zero?
      (part.to_f / total * 100).round(2)
    end
  end
end
