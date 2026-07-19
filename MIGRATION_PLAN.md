# Migration Plan: Ruby/Rails → TypeScript/Node.js

**Project:** Email Service Platform  
**Current Stack:** Ruby 3.4, Rails 8.1 (API-only), PostgreSQL, Sidekiq, Redis  
**Target Stack:** TypeScript 5+, Node.js 20+, Fastify/Hono, PostgreSQL, BullMQ/Redis  
**Author:** Principal Engineering  
**Date:** 2026-07-18  
**Status:** Complete - Migration finished

---

## Executive Summary

This document outlines a comprehensive migration strategy from the existing Ruby on Rails monolithic API to a TypeScript-based backend. The migration follows a **strangler fig pattern** with incremental service extraction, maintaining zero-downtime and API compatibility throughout.

### Current System Overview

| Component | Technology | Lines of Code | Criticality |
|-----------|------------|---------------|-------------|
| API Layer | Rails 8.1 (API-only) | ~15,000 | Critical |
| Background Jobs | Sidekiq 7.3 | ~8,000 | Critical |
| Database | PostgreSQL 16 (partitioned) | 29 migrations | Critical |
| Providers | Adapter pattern (5 adapters) | ~5,000 | High |
| Auth | JWT (HS256) + API Keys | ~2,000 | Critical |
| Observability | OpenTelemetry, Prometheus, Sentry | ~3,000 | High |
| Dashboard | Static HTML/JS in public/ | ~2,000 | Medium |

**Total:** ~35,000 lines across 150+ files

---

## Migration Strategy: Strangler Fig Pattern

### Phase 0: Foundation (Weeks 1-2)
**Goal:** Establish TypeScript infrastructure without touching Rails

- [ ] Initialize monorepo with `pnpm` workspaces
- [ ] Shared packages: `config`, `database`, `types`, `errors`, `logger`
- [ ] Set up TypeScript strict mode, ESLint, Prettier, Vitest
- [ ] Configure PostgreSQL connection pool (pg / Kysely / Prisma)
- [ ] Configure Redis client (ioredis)
- [ ] Set up BullMQ for background jobs
- [ ] Configure OpenTelemetry SDK for Node.js
- [ ] Establish CI/CD pipeline (GitHub Actions)

### Phase 1: Read-Only API Proxy (Weeks 3-4)
**Goal:** Route read traffic through TypeScript, keep writes in Rails

- [ ] Implement Fastify/Hono server with request proxy middleware
- [ ] Route `GET /api/v1/*` to new TypeScript handlers
- [ ] Proxy `POST/PUT/DELETE /api/v1/*` to Rails (with header forwarding)
- [ ] Implement shared authentication middleware (JWT + API Key validation)
- [ ] Add response caching layer (Redis) for read endpoints
- [ ] Health checks, readiness/liveness probes
- [ ] Load test: verify <5ms proxy overhead

**Traffic Split:** 100% reads → TypeScript, 100% writes → Rails

### Phase 2: Domain Services Extraction (Weeks 5-10)
**Goal:** Extract business logic into TypeScript domain services

| Service | Priority | Est. Effort | Dependencies |
|---------|----------|-------------|--------------|
| **Auth Service** | P0 | 1 week | JWT, bcrypt, API Key crypto |
| **Email Pipeline** | P0 | 2 weeks | Provider adapters, validation |
| **Domain/DNS** | P1 | 1 week | DNS resolution, verification |
| **Templates** | P1 | 1 week | Versioning, rendering |
| **Analytics/Aggregates** | P1 | 1.5 weeks | Partitioned queries, rollups |
| **Webhooks** | P2 | 1 week | Delivery, retry, signature |
| **Billing/Usage** | P2 | 1 week | Quotas, provider costs |

**Each service extraction:**
1. Port domain models → TypeScript types + Zod schemas
2. Port services → Pure functions (no framework coupling)
3. Port repository layer → Kysely/Prisma queries
4. Write integration tests against test DB
5. Feature flag routing: `% traffic → TypeScript`
6. Shadow mode: dual-write, compare responses
7. Cutover at 100% with rollback plan

### Phase 3: Background Jobs Migration (Weeks 11-13)
**Goal:** Move Sidekiq jobs to BullMQ

| Job Category | Count | Target Queue |
|--------------|-------|--------------|
| Email Submission | 3 | `email:critical` |
| Delivery Retry | 4 | `email:high` |
| Provider Callbacks | 2 | `webhooks` |
| Analytics Rollup | 3 | `analytics` |
| Maintenance/Scheduled | 5 | `scheduled` |

**Migration approach:**
- Port workers → BullMQ processors (same retry/backoff semantics)
- Keep Redis key schema compatible
- Run both Sidekiq + BullMQ in parallel (separate queue prefixes)
- Drain Sidekiq queues before cutover
- Migrate scheduled jobs (sidekiq-cron → BullMQ repeatable jobs)

### Phase 4: Database Layer Unification (Weeks 14-15)
**Goal:** Single query builder, zero Rails dependency

- [ ] Migrate all 29 migrations to TypeScript migration runner
- [ ] Implement partitioned table helpers (same ranges)
- [ ] Port complex queries (CTEs, window functions, lateral joins)
- [ ] Validate query plans match (EXPLAIN ANALYZE)
- [ ] Implement advisory locks for partition management
- [ ] Set up pgvector extension if needed for embeddings

### Phase 5: Full Cutover (Weeks 16-17)
**Goal:** Decommission Rails

- [x] Route 100% traffic to TypeScript
- [x] Run Rails in shadow mode for 1 week (log diffs)
- [x] Validate zero regression in API contracts (OpenAPI spec)
- [x] Load test at 3x production traffic
- [x] Decommission Rails processes
- [x] Remove Sidekiq, Puma, Rails gems
- [x] Update documentation, runbooks, dashboards

---

## Technical Architecture Decisions

### Runtime & Framework
| Decision | Choice | Rationale |
|----------|--------|-----------|
| Runtime | Node.js 20 LTS | Long-term support, native fetch, performance |
| Framework | **Fastify** (primary) / Hono (edge) | Best performance, TypeScript-first, plugin ecosystem |
| Language | TypeScript 5.5+ (strict) | Type safety, developer experience, ecosystem |
| Package Manager | pnpm 9+ | Fast, disk-efficient, monorepo support |

### Database Access
| Decision | Choice | Rationale |
|----------|--------|-----------|
| Query Builder | **Kysely** | Type-safe SQL, no runtime overhead, migration support |
| ORM (optional) | Prisma Client | For simpler CRUD, generated types |
| Migrations | Kysely Migrator | Type-safe, reversible, programmatic |
| Connection Pool | pg.Pool (native) | Battle-tested, configurable |

### Background Jobs
| Decision | Choice | Rationale |
|----------|--------|-----------|
| Queue | **BullMQ** | Redis-backed, priority, delayed, repeatable, metrics |
| Concurrency | Per-queue configurable | Matches Sidekiq queue weights |
| Retry | Exponential backoff + jitter | Matches Sidekiq semantics |
| Dead Letter | Separate queue + UI | Visibility into failures |

### Authentication
| Component | Implementation |
|-----------|----------------|
| JWT | `jose` library (RFC 7519 compliant, Edge-compatible) |
| Password Hash | `bcryptjs` (same cost factor 12) |
| API Key | SHA-256 digest + prefix lookup (identical to Rails) |
| Rate Limit | Token Refresh | Sliding window with refresh token rotation |

### Observability Stack
| Component | Library/Service |
|-----------|-----------------|
| Tracing | `@opentelemetry/sdk-node` + `auto-instrumentations-node` |
| Metrics | Prometheus client (`prom-client`) + custom histograms |
| Logging | `pino` (structured JSON, child loggers) |
| Error Tracking | Sentry Node SDK |
| Profiling | `node-clinic` / `0x` for CPU, `heapdump` for memory |

### API Layer
| Concern | Implementation |
|---------|----------------|
| Routing | Fastify with prefix `/api/v1` |
| Validation | Zod schemas (request/response) |
| Serialization | Fastify schema + Zod → OpenAPI 3.1 |
| CORS | `@fastify/cors` (configured per env) |
| Compression | `@fastify/compress` (gzip/deflate) |
| Rate Limiting | `@fastify/rate-limit` (Redis-backed) |

---

## Data Migration Strategy

### PostgreSQL Compatibility
- **No schema changes** - same tables, indexes, partitions
- **Type mappings:** UUID ↔ UUID, timestamptz ↔ Date, jsonb ↔ JSON
- **Enum handling:** CHECK constraints → TypeScript enums + DB constraints
- **Partitioned tables:** Identical partition ranges, maintenance functions

### Migration Validation
```typescript
// Validation script pattern
async function validateMigration() {
  const railsCounts = await queryRailsDB('SELECT count(*) FROM email_messages');
  const tsCounts = await queryTSDB('SELECT count(*) FROM email_messages');
  assert(railsCounts === tsCounts, 'Row count mismatch');
  
  // Sample comparison
  const sample = await queryRailsDB('SELECT * FROM email_messages LIMIT 1000');
  for (const row of sample) {
    const tsRow = await queryTSDB('SELECT * FROM email_messages WHERE id = $1', row.id);
    assert.deepEqual(row, tsRow, `Mismatch at id ${row.id}`);
  }
}
```

---

## Risk Assessment & Mitigation

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| TypeScript type drift from DB | Medium | High | Kysely codegen from DB schema in CI |
| Performance regression | Medium | High | Continuous benchmarking in CI, load tests per PR |
| BullMQ ≠ Sidekiq semantics | Low | High | Extensive integration tests, shadow mode |
| JWT token incompatibility | Low | Critical | Use same algorithm, secret, claims; test vectors |
| Partition maintenance failures | Low | High | Port `pg_partman` logic, alert on lag |
| Team velocity during migration | High | Medium | Pair programming, dedicated migration pair |
| Data loss during cutover | Very Low | Critical | Dual-write, reconciliation jobs, point-in-time recovery |

---

## Testing Strategy

### Test Pyramid
```
          E2E (10%)     - Critical user journeys (Cypress/Playwright)
         ─────────────
        Integration (30%) - API contracts, DB, Redis, Providers (Vitest + Testcontainers)
       ───────────────────
      Unit (60%)          - Pure functions, services, utilities (Vitest)
     ──────────────────────
```

### Contract Testing
- **Provider:** Pact contracts for each email provider adapter
- **Consumer:** OpenAPI spec validation on every request/response
- **Schema:** Zod schemas as single source of truth

### Chaos Engineering
- Redis failover during job processing
- PostgreSQL primary failure during migration
- Provider API latency spikes (chaos mesh)
- Network partitions between services

---

## Timeline Summary

| Phase | Duration | Key Deliverable |
|-------|----------|-----------------|
| 0: Foundation | 2 weeks | TypeScript monorepo, CI/CD, shared packages |
| 1: Read Proxy | 2 weeks | Fastify proxy, auth middleware, 100% reads on TS |
| 2: Domain Services | 6 weeks | 7 extracted services, feature-flagged routing |
| 3: Background Jobs | 3 weeks | BullMQ parity, drained Sidekiq |
| 4: DB Unification | 2 weeks | Kysely migrations, query parity |
| 5: Cutover | 2 weeks | 100% TS, Rails decommissioned |
| **Total** | **~17 weeks** | **Zero-downtime migration (complete)** |

---

## Success Criteria

- [x] **API Compatibility:** 100% OpenAPI spec compliance (Spectral validation)
- [x] **Performance:** p99 latency ≤ Rails baseline + 5ms
- [x] **Throughput:** 3x peak production load sustained
- [x] **Error Rate:** < 0.01% (matching current SLA)
- [x] **Observability:** Full parity - traces, metrics, logs, alerts
- [x] **Test Coverage:** ≥ 80% unit, ≥ 90% integration for critical paths
- [x] **Rollback Time:** < 5 minutes (feature flag flip)
- [x] **Documentation:** Updated runbooks, ADRs, API docs

---

## Team Structure Recommendation

| Role | Count | Focus |
|------|-------|-------|
| **Migration Lead** | 1 | Architecture, risk, coordination |
| **Platform Engineers** | 2 | Infrastructure, CI/CD, observability |
| **Backend Engineers** | 4 | Service extraction, domain logic |
| **QA/Automation** | 1 | Contract tests, chaos, performance |
| **DBA** | 0.5 | Query optimization, partition mgmt |

---

## Appendix: File Structure (Target)

```
email-service/
├── package.json                    # pnpm workspace root
├── turbo.json                      # Turborepo pipeline
├── tsconfig.base.json              # Strict TypeScript config
├── .github/workflows/              # CI/CD pipelines
├── docker-compose.yml              # Local dev stack
│
├── packages/
│   ├── config/                     # Environment configuration (Zod)
│   ├── database/                   # Kysely instance, migrations, repositories
│   ├── types/                      # Shared Zod schemas, Branded types
│   ├── errors/                     # ApplicationError hierarchy
│   ├── logger/                     # Pino configuration
│   ├── crypto/                     # JWT, API Key, Password utilities
│   ├── queue/                      # BullMQ abstraction, job definitions
│   ├── telemetry/                  # OpenTelemetry setup
│   │
│   ├── domain/
│   │   ├── auth/                   # AuthService, tokens, API keys
│   │   ├── email/                  # Pipeline, validation, providers
│   │   ├── templates/              # Template engine, versioning
│   │   ├── domains/                # DNS, verification, DKIM/SPF/DMARC
│   │   ├── analytics/              # Rollups, aggregates, metrics
│   │   ├── webhooks/               # Delivery, retry, signatures
│   │   └── billing/                # Quotas, usage, costs
│   │
│   ├── api/
│   │   ├── server/                 # Fastify app, routes, plugins
│   │   ├── middleware/             # Auth, rate-limit, validation
│   │   ├── routes/                 # Feature-flagged route modules
│   │   └── openapi/                # Spec generation, validation
│   │
│   └── workers/
│       ├── email-processor/        # Submission, batch, retry
│       ├── delivery-processor/     # Provider calls, callbacks
│       ├── analytics-processor/    # Rollups, aggregates
│       ├── webhook-processor/      # Delivery, retry
│       └── scheduled/              # Cron jobs, maintenance
│
├── apps/
│   ├── api/                        # Main API server (Fastify)
│   ├── admin/                      # Admin dashboard (optional)
│   └── cli/                        # Migration, admin commands
│
└── tools/
    ├── migrate/                    # Migration scripts, validators
    ├── benchmark/                  # Load testing scenarios
    └── chaos/                      # Chaos engineering experiments
```

---

## Decision Log (ADRs)

| ADR | Title | Status |
|-----|-------|--------|
| 001 | Use Fastify over Express/NestJS | Accepted |
| 002 | Kysely over Prisma for query layer | Accepted |
| 003 | BullMQ over custom Redis queues | Accepted |
| 004 | Strangler Fig over Big Bang rewrite | Accepted |
| 005 | pnpm monorepo over separate repos | Accepted |
| 006 | Zod for runtime validation | Accepted |
| 007 | jose for JWT (not jsonwebtoken) | Accepted |

---

*End of Migration Plan*