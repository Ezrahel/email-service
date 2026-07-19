class ApplicationService
  def self.call(*args, **kwargs)
    new(*args, **kwargs).call
  end

  def initialize(*args, **kwargs)
    @args = args
    @kwargs = kwargs
  end

  def call
    raise NotImplementedError, "#{self.class} must implement #call"
  end

  private

  attr_reader :args, :kwargs
end
