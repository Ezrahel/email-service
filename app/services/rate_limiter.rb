class RateLimiter
  def initialize(key, limit: nil, period: nil)
    @key = "rate_limit:#{key}"
    @limit = limit || ENV.fetch("RATE_LIMIT_EMAILS_PER_SECOND", 50).to_i
    @period = period || 1.second
  end

  def allow?
    count = redis.get(@key).to_i
    return true if count < @limit

    false
  end

  def retry_after
    ttl = redis.ttl(@key)
    [ttl, 0].max
  end

  def increment!
    redis.multi do |pipeline|
      pipeline.incr(@key)
      pipeline.expire(@key, @period.to_i)
    end
  end

  private

  def redis
    REDIS_POOL.with { |conn| conn }
  end
end
