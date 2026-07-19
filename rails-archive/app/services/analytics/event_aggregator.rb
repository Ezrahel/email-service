module Analytics
  class EventAggregator < ApplicationService
    WINDOWS = {
      "1m"  => { duration: 1.minute,  granularity: "1m" },
      "5m"  => { duration: 5.minutes, granularity: "5m" },
      "1h"  => { duration: 1.hour,    granularity: "hourly" },
      "1d"  => { duration: 1.day,     granularity: "daily" },
      "30d" => { duration: 30.days,   granularity: "monthly" }
    }.freeze

    METRICS = %w[
      emails_sent emails_delivered opens clicks
      bounces complaints provider_errors delivery_latency
    ].freeze

    def initialize(window: "1h", force_replay: false)
      @window = window
      @force_replay = force_replay
    end

    def call
      config = WINDOWS[@window]
      raise ArgumentError, "Unknown window: #{@window}" unless config

      since = @force_replay ? 30.days.ago : config[:duration].ago
      cutoff = Time.current

      aggregate_email_volume(config[:granularity], since, cutoff)
      aggregate_engagement(config[:granularity], since, cutoff)
      aggregate_latency(config[:granularity], since, cutoff)
      aggregate_provider_errors(config[:granularity], since, cutoff)

      { aggregated: true, window: @window, since: since, until: cutoff }
    end

    def self.replay_all!
      WINDOWS.keys.each do |w|
        new(window: w, force_replay: true).call
      end
    end

    private

    def aggregate_email_volume(granularity, since, cutoff)
      bucket_expr = bucket_expression(granularity, "email_messages.created_at")

      rows = EmailMessage
        .where(created_at: since..cutoff)
        .group(bucket_expr, :organization_id)
        .select(
          "#{bucket_expr} AS bucket",
          :organization_id,
          "COUNT(*) AS total",
          "COUNT(*) FILTER (WHERE status IN ('delivered','sent')) AS delivered",
          "COUNT(*) FILTER (WHERE status = 'failed') AS failed",
          "COUNT(*) FILTER (WHERE status = 'bounced') AS bounced",
          "COUNT(*) FILTER (WHERE status = 'queued') AS queued"
        )

      rows.each do |r|
        upsert(r.organization_id, "emails_sent", granularity, r.bucket) do |a|
          a.total_count = r.total
          a.delivered_count = r.delivered
          a.failed_count = r.failed
          a.bounced_count = r.bounced
          a.queued_count = r.queued
          compute_rates(a)
        end
      end
    end

    def aggregate_engagement(granularity, since, cutoff)
      bucket_expr = bucket_expression(granularity, "de.event_timestamp")

      rows = DeliveryEvent
        .where(event_timestamp: since..cutoff)
        .where(event_type: %w[opened clicked complained])
        .group(bucket_expr, :organization_id, :event_type)
        .select(
          "#{bucket_expr} AS bucket",
          :organization_id,
          :event_type,
          "COUNT(*) AS cnt"
        )

      grouped = rows.group_by { |r| [r.organization_id, r.bucket] }
      grouped.each do |(org_id, bucket), events|
        counts = events.each_with_object({ opened: 0, clicked: 0, complained: 0 }) do |e, h|
          key = e.event_type.to_sym
          h[key] = e.cnt if h.key?(key)
        end

        upsert(org_id, "emails_sent", granularity, bucket) do |a|
          a.opened_count = counts[:opened]
          a.clicked_count = counts[:clicked]
          a.complained_count = counts[:complained]
          compute_rates(a)
        end
      end
    end

    def aggregate_latency(granularity, since, cutoff)
      bucket_expr = bucket_expression(granularity, "d.last_attempt_at")

      rows = Delivery
        .where(last_attempt_at: since..cutoff)
        .where.not(last_attempt_duration_ms: nil)
        .group(bucket_expr, :organization_id)
        .select(
          "#{bucket_expr} AS bucket",
          :organization_id,
          "AVG(last_attempt_duration_ms) AS avg_ms",
          "percentile_cont(0.50) WITHIN GROUP (ORDER BY last_attempt_duration_ms) AS p50",
          "percentile_cont(0.90) WITHIN GROUP (ORDER BY last_attempt_duration_ms) AS p90",
          "percentile_cont(0.99) WITHIN GROUP (ORDER BY last_attempt_duration_ms) AS p99"
        )

      rows.each do |r|
        upsert(r.organization_id, "delivery_latency", granularity, r.bucket) do |a|
          a.avg_delivery_latency_ms = r.avg_ms
          a.p50_latency_ms = r.p50
          a.p90_latency_ms = r.p90
          a.p99_latency_ms = r.p99
        end
      end
    end

    def aggregate_provider_errors(granularity, since, cutoff)
      bucket_expr = bucket_expression(granularity, "pa.created_at")

      rows = ProviderAttempt
        .where(created_at: since..cutoff)
        .where(status: "failed")
        .group(bucket_expr, :organization_id, :provider)
        .select(
          "#{bucket_expr} AS bucket",
          :organization_id,
          :provider,
          "COUNT(*) AS error_count"
        )

      rows.each do |r|
        metric = "provider_errors:#{r.provider}"
        upsert(r.organization_id, metric, granularity, r.bucket) do |a|
          a.total_count = r.error_count
          a.failed_count = r.error_count
        end
      end
    end

    def upsert(org_id, metric_name, granularity, bucket)
      aggregate = Aggregate.find_or_initialize_by(
        organization_id: org_id,
        metric_name: metric_name,
        granularity: granularity,
        bucket: bucket
      )
      yield aggregate
      aggregate.save! if aggregate.changed?
    rescue ActiveRecord::RecordNotUnique
      retry
    end

    def compute_rates(a)
      return unless a.total_count&.positive?

      a.delivery_rate = (a.delivered_count.to_f / a.total_count * 100).round(4)
      a.bounce_rate = (a.bounced_count.to_f / a.total_count * 100).round(4)
      a.complaint_rate = (a.complained_count.to_f / a.total_count * 100).round(4)

      if a.delivered_count.positive?
        a.open_rate = (a.opened_count.to_f / a.delivered_count * 100).round(4)
      end
      if a.opened_count.positive?
        a.click_rate = (a.clicked_count.to_f / a.opened_count * 100).round(4)
      end
    end

    def bucket_expression(granularity, column)
      case granularity
      when "1m"      then "date_trunc('minute', #{column})"
      when "5m"      then "date_trunc('minute', #{column}) - (EXTRACT(MINUTE FROM #{column})::int %% 5) * interval '1 minute'"
      when "hourly"  then "date_trunc('hour', #{column})"
      when "daily"   then "date_trunc('day', #{column})"
      when "monthly" then "date_trunc('month', #{column})"
      else "date_trunc('hour', #{column})"
      end
    end
  end
end
