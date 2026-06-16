class RateLimitExceeded < StandardError
  attr_reader :retry_after

  def initialize(retry_after: 0)
    @retry_after = retry_after
    super("Rate limit exceeded. Try again in #{retry_after} seconds.")
  end
end
