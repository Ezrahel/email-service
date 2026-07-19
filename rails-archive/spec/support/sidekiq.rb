require "sidekiq/testing"

Sidekiq::Testing.fake!

RSpec.configure do |config|
  config.before(:each) do
    Sidekiq::Worker.clear_all
  end

  config.around(:each, :sidekiq_inline) do |example|
    Sidekiq::Testing.inline! { example.run }
  ensure
    Sidekiq::Testing.fake!
  end
end
