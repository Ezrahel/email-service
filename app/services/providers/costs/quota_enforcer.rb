module Providers
  module Costs
    class QuotaEnforcer
      QuotaResult = Struct.new(:allowed?, :current_usage, :limit, :reason, keyword_init: true)

      class << self
        def check_send(organization)
          return check_plan_quota(organization) unless organization.monthly_email_quota.to_i > 0

          monthly = UsageMeter.monthly_count(organization.id)

          if monthly >= organization.monthly_email_quota
            QuotaResult.new(
              allowed?: false,
              current_usage: monthly,
              limit: organization.monthly_email_quota,
              reason: "Monthly quota exceeded (#{monthly}/#{organization.monthly_email_quota})"
            )
          else
            QuotaResult.new(
              allowed?: true,
              current_usage: monthly,
              limit: organization.monthly_email_quota
            )
          end
        end

        def check_rate_limit(organization)
          rate_limit = organization.rate_limit_per_second || 10
          key = "rate:#{organization.id}:#{Time.current.to_i / 10}"

          current = REDIS_POOL.with do |conn|
            conn.incr(key)
            conn.expire(key, 12)
            conn.get(key).to_i
          end

          if current > rate_limit * 10
            QuotaResult.new(
              allowed?: false,
              current_usage: current,
              limit: rate_limit * 10,
              reason: "Rate limit exceeded (#{current}/#{rate_limit * 10} per 10s)"
            )
          else
            QuotaResult.new(
              allowed?: true,
              current_usage: current,
              limit: rate_limit * 10
            )
          end
        end

        def check_daily_limit(organization)
          daily_limit = organization.daily_email_quota || (organization.monthly_email_quota.to_i / 30)
          return QuotaResult.new(allowed?: true) if daily_limit <= 0

          daily = UsageMeter.daily_count(organization.id)

          if daily >= daily_limit
            QuotaResult.new(
              allowed?: false,
              current_usage: daily,
              limit: daily_limit,
              reason: "Daily quota exceeded (#{daily}/#{daily_limit})"
            )
          else
            QuotaResult.new(
              allowed?: true,
              current_usage: daily,
              limit: daily_limit
            )
          end
        end

        def check_all(organization)
          results = {
            monthly: check_send(organization),
            daily: check_daily_limit(organization),
            rate: check_rate_limit(organization)
          }

          denied = results.values.find { |r| !r.allowed? }
          denied || results[:monthly]
        end

        private

        def check_plan_quota(organization)
          case organization.plan
          when "free"
            limit = 100
          when "starter"
            limit = 10_000
          when "growth"
            limit = 100_000
          when "enterprise"
            limit = 1_000_000
          else
            return QuotaResult.new(allowed?: true)
          end

          monthly = UsageMeter.monthly_count(organization.id)

          if monthly >= limit
            QuotaResult.new(
              allowed?: false,
              current_usage: monthly,
              limit: limit,
              reason: "Plan limit exceeded (#{monthly}/#{limit})"
            )
          else
            QuotaResult.new(
              allowed?: true,
              current_usage: monthly,
              limit: limit
            )
          end
        end
      end
    end
  end
end
