module Monitoring
  class QueueHealthMonitor < ApplicationService
    QUEUES = %w[default email analytics webhooks providers maintenance].freeze

    def call
      {
        timestamp: Time.current.iso8601,
        total_enqueued: total_enqueued,
        queues: queue_details,
        workers: worker_details,
        retries: retry_details,
        scheduled: scheduled_details,
        dead: dead_details,
        alerts: generate_alerts
      }
    end

    private

    def total_enqueued
      Sidekiq::Stats.new.enqueued
    rescue StandardError
      0
    end

    def queue_details
      QUEUES.each_with_object({}) do |name, h|
        queue = Sidekiq::Queue.new(name)
        h[name] = {
          depth: queue.size,
          latency: queue.latency.round(2),
          paused: queue.paused?
        }
      end
    rescue StandardError
      {}
    end

    def worker_details
      workers = Sidekiq::Workers.new
      {
        total: workers.size,
        by_queue: workers.group_by { |_, _, w| w["queue"] }.transform_values(&:size)
      }
    rescue StandardError
      { total: 0, by_queue: {} }
    end

    def retry_details
      retries = Sidekiq::RetrySet.new
      {
        total: retries.size,
        oldest: retries.min&.at&.iso8601
      }
    rescue StandardError
      { total: 0 }
    end

    def scheduled_details
      scheduled = Sidekiq::ScheduledSet.new
      {
        total: scheduled.size
      }
    rescue StandardError
      { total: 0 }
    end

    def dead_details
      dead = Sidekiq::DeadSet.new
      {
        total: dead.size,
        oldest: dead.min&.at&.iso8601
      }
    rescue StandardError
      { total: 0 }
    end

    def generate_alerts
      [].tap do |alerts|
        queue_details.each do |name, info|
          alerts << { queue: name, type: "backlog", severity: "warning", message: "Queue #{name} depth at #{info[:depth]}" } if info[:depth] > 5_000
          alerts << { queue: name, type: "latency", severity: "warning", message: "Queue #{name} latency at #{info[:latency]}s" } if info[:latency] > 300
        end

        retry_info = retry_details
        alerts << { type: "retries", severity: "warning", message: "#{retry_info[:total]} jobs in retry queue" } if retry_info[:total] > 1_000
      end
    end
  end
end
