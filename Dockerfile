# syntax=docker/dockerfile:1

# ── Base ─────────────────────────────────────────────────────────────
FROM node:22-alpine AS base
RUN apk add --no-cache libc6-compat curl tini
RUN corepack enable && corepack prepare pnpm@9.0.0 --activate
ENV PNPM_HOME=/usr/local/share/pnpm
ENV PATH="$PNPM_HOME:$PATH"
WORKDIR /app

# ── Dependencies (manifest-only layer) ────────────────────────────────
FROM base AS deps
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml turbo.json ./
COPY apps/web/package.json apps/web/
COPY packages/api/package.json packages/api/
COPY packages/config/package.json packages/config/
COPY packages/crypto/package.json packages/crypto/
COPY packages/database/package.json packages/database/
COPY packages/domain/package.json packages/domain/
COPY packages/errors/package.json packages/errors/
COPY packages/gateways/smtp/package.json packages/gateways/smtp/
COPY packages/logger/package.json packages/logger/
COPY packages/queue/package.json packages/queue/
COPY packages/sdks/node/package.json packages/sdks/node/
COPY packages/telemetry/package.json packages/telemetry/
COPY packages/tools/mcp/package.json packages/tools/mcp/
COPY packages/tsconfig/package.json packages/tsconfig/
COPY packages/types/package.json packages/types/
COPY packages/workers/analytics-processor/package.json packages/workers/analytics-processor/
COPY packages/workers/delivery-processor/package.json packages/workers/delivery-processor/
COPY packages/workers/email-processor/package.json packages/workers/email-processor/
COPY packages/workers/scheduled/package.json packages/workers/scheduled/
COPY packages/workers/webhook-processor/package.json packages/workers/webhook-processor/
RUN pnpm install --frozen-lockfile

# ── Build all workspace packages via Turborepo ────────────────────────
FROM deps AS build
COPY . .
RUN pnpm build

# ── Prune to production dependencies ──────────────────────────────────
FROM build AS prune
RUN pnpm prune --prod --config.confirmModulesPurge=false

# ── API runtime ───────────────────────────────────────────────────────
FROM base AS api
ENV NODE_ENV=production
WORKDIR /app
COPY --from=prune /app ./
EXPOSE 3000
HEALTHCHECK --interval=10s --timeout=3s --retries=3 \
  CMD wget -qO- http://localhost:3000/health >/dev/null || exit 1
ENTRYPOINT ["tini", "--"]
CMD ["node", "packages/api/dist/server.js"]

# ── Web runtime ───────────────────────────────────────────────────────
FROM base AS web
ENV NODE_ENV=production
WORKDIR /app
COPY --from=prune /app ./
WORKDIR /app/apps/web
EXPOSE 3000
HEALTHCHECK --interval=10s --timeout=3s --retries=3 \
  CMD wget -qO- http://localhost:3000 >/dev/null || exit 1
ENTRYPOINT ["tini", "--"]
CMD ["node", "/app/apps/web/node_modules/next/dist/bin/next", "start", "-p", "3000"]

# ── Worker runtime (shared; deployment overrides command) ─────────────
FROM base AS worker
ENV NODE_ENV=production
WORKDIR /app
COPY --from=prune /app ./
ENTRYPOINT ["tini", "--"]
CMD ["node", "packages/workers/email-processor/dist/index.js"]
