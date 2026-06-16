# ── Build Stage ──────────────────────────────────────────────────
FROM ruby:3.4-slim AS build

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      libpq-dev \
      libcurl4-openssl-dev \
      git \
      ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4 --retry 3 --without development test

# ── Runtime Stage ────────────────────────────────────────────────
FROM ruby:3.4-slim AS runtime

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      libpq-dev \
      libcurl4 \
      ca-certificates \
      tzinfo \
      curl && \
    rm -rf /var/lib/apt/lists/*

RUN groupadd --system --gid 1000 rails && \
    useradd --system --uid 1000 --gid rails --shell /bin/bash --create-home rails

WORKDIR /app

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --chown=rails:rails . .

RUN mkdir -p tmp/pids log && chown -R rails:rails tmp log

USER rails

EXPOSE 3000

HEALTHCHECK --interval=10s --timeout=3s --retries=3 \
  CMD curl -sf http://localhost:3000/health || exit 1

ENTRYPOINT ["/app/bin/docker-entrypoint"]
