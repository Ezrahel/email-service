source "https://rubygems.org"

ruby ">= 3.4"

# ── Framework ────────────────────────────────────────────────
gem "rails", "~> 8.0"
gem "pg", "~> 1.5"
gem "puma", "~> 6.4"
gem "bootsnap", require: false

# ── API & Serialization ──────────────────────────────────────
gem "rack-cors", "~> 2.0"
gem "jsonapi-serializer", "~> 2.2"
gem "kaminari", "~> 1.2"
gem "api-pagination", "~> 5.0"

# ── Authentication & Authorization ───────────────────────────
gem "bcrypt", "~> 3.1"
gem "jwt", "~> 2.8"
gem "rack-attack", "~> 6.7"

# ── Background Jobs ──────────────────────────────────────────
gem "sidekiq", "~> 7.3"
gem "sidekiq-unique-jobs", "~> 8.0"
gem "sidekiq-throttled", "~> 1.2"
gem "sidekiq-status", "~> 3.0"
gem "sidekiq-cron", "~> 2.0"

# ── Redis ────────────────────────────────────────────────────
gem "redis", "~> 5.2"
gem "redis-client", "~> 0.22"
gem "connection_pool", "~> 2.4"

# ── Email Providers ──────────────────────────────────────────
gem "aws-sdk-sesv2", "~> 1.0"
gem "mailgun-ruby", "~> 1.2"
gem "sendgrid-ruby", "~> 6.7"
gem "postmark", "~> 1.25"
gem "net-smtp", "~> 0.5"
gem "mail", "~> 2.8"

# ── Resilience ───────────────────────────────────────────────
gem "circuitbox", "~> 2.1"
gem "retriable", "~> 3.1"

# ── Observability ────────────────────────────────────────────
gem "lograge", "~> 0.14"
gem "logstash-event", "~> 1.2"
gem "opentelemetry-sdk", "~> 1.5"
gem "opentelemetry-exporter-otlp", "~> 0.29"
gem "opentelemetry-instrumentation-all", "~> 0.64"
gem "sentry-ruby", "~> 5.18"
gem "sentry-rails", "~> 5.18"
gem "sentry-sidekiq", "~> 5.18"
gem "prometheus_exporter", "~> 2.1"

# ── Storage ──────────────────────────────────────────────────
gem "aws-sdk-s3", "~> 1.160"

# ── DNS & Domain Verification ────────────────────────────────
gem "resolv", "~> 0.4"
gem "dnsbl-rb", "~> 1.0"

# ── OpenAPI / API Docs ───────────────────────────────────────
gem "rswag-api", "~> 2.14"
gem "rswag-ui", "~> 2.14"

# ── Encryption ───────────────────────────────────────────────
gem "lockbox", "~> 1.3"
gem "blind_index", "~> 2.4"

# ── Utilities ────────────────────────────────────────────────
gem "jbuilder", "~> 2.12"
gem "oj", "~> 3.16"
gem "dotenv-rails", "~> 3.1"
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]

group :development, :test do
  gem "rspec-rails", "~> 7.0"
  gem "factory_bot_rails", "~> 6.4"
  gem "faker", "~> 3.4"
  gem "pry-rails", "~> 0.3"
  gem "pry-byebug", "~> 3.10"
  gem "rubocop", "~> 1.66"
  gem "rubocop-rails", "~> 2.25"
  gem "rubocop-rspec", "~> 3.1"
  gem "rubocop-performance", "~> 1.21"
  gem "shoulda-matchers", "~> 6.4"
  gem "database_cleaner-active_record", "~> 2.1"
  gem "rswag-specs", "~> 2.14"
end

group :test do
  gem "simplecov", "~> 0.22", require: false
  gem "webmock", "~> 3.23"
  gem "vcr", "~> 6.3"
  gem "timecop", "~> 0.9"
  gem "email_spec", "~> 2.2"
end

group :development do
  gem "listen", "~> 3.9"
  gem "spring", "~> 4.2"
  gem "spring-commands-rspec", "~> 1.0"
  gem "annotate", "~> 3.2"
  gem "letter_opener", "~> 1.10"
end
