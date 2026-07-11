module Analytics
  class ReportGenerator < ApplicationService
    FORMATS = %w[json csv pdf].freeze

    def initialize(organization:, report_type:, since: 30.days.ago, until_time: Time.current, format: "json")
      @organization = organization
      @report_type = report_type
      @since = since
      @until = until_time
      @format = format
    end

    def call
      raise ArgumentError, "Unknown format: #{@format}" unless FORMATS.include?(@format)

      data = build_report
      return data if @format == "json"

      convert_format(data)
    end

    private

    def build_report
      case @report_type
      when "delivery_summary"
        delivery_summary
      when "engagement"
        engagement_report
      when "provider_performance"
        provider_performance
      when "cost_analysis"
        cost_analysis
      when "compliance"
        compliance_report
      else
        raise ArgumentError, "Unknown report type: #{@report_type}"
      end
    end

    def delivery_summary
      messages = @organization.email_messages.where(created_at: @since..@until)
      by_status = messages.group(:status).count

      {
        report_type: "delivery_summary",
        period: { since: @since, until: @until },
        organization_id: @organization.id,
        generated_at: Time.current,
        totals: {
          total: messages.count,
          by_status: by_status,
          delivery_rate: rate(by_status.fetch("delivered", 0), messages.count),
          bounce_rate: rate(by_status.fetch("bounced", 0), messages.count)
        },
        daily_totals: messages
          .group("date_trunc('day', created_at)")
          .select("date_trunc('day', created_at) AS day", "COUNT(*) AS cnt", "COUNT(*) FILTER (WHERE status = 'delivered') AS delivered")
          .order("day ASC")
          .map { |r| { date: r.day, total: r.cnt.to_i, delivered: r.delivered.to_i } }
      }
    end

    def engagement_report
      messages = @organization.email_messages.where(created_at: @since..@until)

      {
        report_type: "engagement",
        period: { since: @since, until: @until },
        organization_id: @organization.id,
        generated_at: Time.current,
        opens: {
          total: messages.joins(:delivery).where(deliveries: { open_count: 1.. }).count,
          unique: messages.joins(:delivery).where(deliveries: { open_count: 1.. }).count
        },
        clicks: {
          total: messages.joins(:delivery).where(deliveries: { click_count: 1.. }).count,
          unique: messages.joins(:delivery).where(deliveries: { click_count: 1.. }).count
        },
        complaints: messages.joins(:delivery).where.not(deliveries: { complaint_at: nil }).count,
        open_rate: rate(
          messages.joins(:delivery).where(deliveries: { open_count: 1.. }).count,
          messages.where(status: "delivered").count
        ),
        click_through_rate: rate(
          messages.joins(:delivery).where(deliveries: { click_count: 1.. }).count,
          messages.joins(:delivery).where(deliveries: { open_count: 1.. }).count
        )
      }
    end

    def provider_performance
      {
        report_type: "provider_performance",
        period: { since: @since, until: @until },
        organization_id: @organization.id,
        generated_at: Time.current,
        providers: ProviderAttempt
          .joins(delivery: :email_message)
          .where(email_messages: { organization_id: @organization.id })
          .where(provider_attempts: { created_at: @since..@until })
          .group(:provider)
          .select(
            :provider,
            "COUNT(*) AS total",
            "COUNT(*) FILTER (WHERE status = 'success') AS success",
            "COUNT(*) FILTER (WHERE status = 'failed') AS failed",
            "AVG(duration_ms)::numeric(10,2) AS avg_duration_ms"
          )
          .order("total DESC")
          .map { |r| { provider: r.provider, total: r.total.to_i, success: r.success.to_i, failed: r.failed.to_i, avg_duration_ms: r.avg_duration_ms } }
      }
    end

    def cost_analysis
      {
        report_type: "cost_analysis",
        period: { since: @since, until: @until },
        organization_id: @organization.id,
        generated_at: Time.current,
        costs: UsageRecord
          .for_organization(@organization)
          .for_metric("emails_sent")
          .where(bucket: @since..@until)
          .select("SUM(count) AS total", "SUM(cost) AS total_cost")
          .take
      }
    end

    def compliance_report
      {
        report_type: "compliance",
        period: { since: @since, until: @until },
        organization_id: @organization.id,
        generated_at: Time.current,
        bounces: bounce_breakdown,
        complaints: complaint_breakdown,
        unsubscribes: @organization.delivery_events
          .by_type("unsubscribed")
          .since(@since)
          .count
      }
    end

    def bounce_breakdown
      @organization.delivery_events
        .by_type("bounced")
        .since(@since)
        .group(:provider)
        .count
    end

    def complaint_breakdown
      @organization.delivery_events
        .by_type("complained")
        .since(@since)
        .group(:provider)
        .count
    end

    def convert_format(data)
      case @format
      when "csv"
        convert_to_csv(data)
      when "pdf"
        { error: "PDF generation requires a background job", data: data }
      end
    end

    def convert_to_csv(data)
      headers = extract_headers(data)
      lines = [headers.join(",")]
      extract_rows(data, headers).each { |row| lines << row.join(",") }
      lines.join("\n")
    end

    def extract_headers(hash, prefix = "")
      hash.each_with_object([]) do |(k, v), arr|
        key = prefix.empty? ? k.to_s : "#{prefix}.#{k}"
        if v.is_a?(Hash)
          arr.concat(extract_headers(v, key))
        elsif v.is_a?(Array) && v.first.is_a?(Hash)
          arr.concat(v.first.keys.map { |sk| "#{key}.#{sk}" })
        else
          arr << key
        end
      end
    end

    def extract_rows(hash, headers)
      [headers.map { |h| hash.dig(*h.split(".")).to_s }]
    rescue StandardError
      [[hash.to_s]]
    end

    def rate(part, total)
      return 0.0 if total.zero?
      (part.to_f / total * 100).round(2)
    end
  end
end
