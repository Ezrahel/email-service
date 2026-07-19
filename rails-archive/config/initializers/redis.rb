require "connection_pool"
require "redis"

RedisClient.singleton_class.prepend(Module.new do
  def configure(**kwargs)
    super
  end
end)

# General-purpose Redis connection pool
REDIS_POOL = ConnectionPool.new(size: ENV.fetch("RAILS_MAX_THREADS", 10).to_i + 5) do
  Redis.new(url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0"))
end

# Redis streams connection
REDIS_STREAMS = Redis.new(url: ENV.fetch("REDIS_STREAMS_URL", "redis://localhost:6379/3"))

# Expose a convenience method
module RedisHelper
  def redis_pool
    REDIS_POOL
  end

  def redis_streams
    REDIS_STREAMS
  end
end
