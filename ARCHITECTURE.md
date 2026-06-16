# Email Delivery Platform — Architecture

## Phase 1: High-Level Architecture

---

## 1. System Overview

A multi-tenant, API-first transactional email service built on Ruby on Rails (API-only), backed by PostgreSQL, Redis, and Sidekiq. Designed for horizontal scaling, provider failover, and full observability.

```
                         ┌──────────────────────────────────────────────────────────┐
                         │                     Internet / Clients                    │
                         └──────────┬──────────────────────────────┬────────────────┘
                                    │                              │
                          ┌────────▼────────┐            ┌─────────▼─────────┐
                          │   Public API     │            │    Dashboard UI    │
                          │   (REST v1)      │            │   (Rails / SPA)    │
                          └────────┬────────┘            └─────────┬─────────┘
                                   │                               │
                          ┌────────▼────────────────────────────────▼─────────┐
                          │              API Gateway / Reverse Proxy           │
                          │           (Nginx / Traefik / ALB)                  │
                          │  ┌─ Rate Limiting ─┐ ┌─ Auth (API Key / JWT) ─┐  │
                          │  └─────────────────┘ └─────────────────────────┘  │
                          └────────────────────────┬──────────────────────────┘
                                                   │
                          ┌────────────────────────▼──────────────────────────┐
                          │              Rails API Application                 │
                          │  ┌──────────────┐ ┌──────────────┐ ┌────────────┐ │
                          │  │  Auth Module  │ │  Email API   │ │  Domain    │ │
                          │  │  (API Keys)   │ │  (CRUD)      │ │  Manager   │ │
                          │  └──────────────┘ └──────┬───────┘ └────────────┘ │
                          │  ┌──────────────┐ ┌──────┴───────┐ ┌────────────┐ │
                          │  │  Templates   │ │  Webhooks    │ │  Analytics  │ │
                          │  │  Engine      │ │  Dispatcher  │ │  API        │ │
                          │  └──────────────┘ └──────────────┘ └────────────┘ │
                          └────────────────────────┬──────────────────────────┘
                                                   │
                          ┌────────────────────────▼──────────────────────────┐
                          │              Background Processing                 │
                          │  ┌──────────────────────────────────────────────┐  │
                          │  │            Sidekiq (Redis)                   │  │
                          │  │  ┌──────────┐ ┌──────────┐ ┌──────────────┐ │  │
                          │  │  │Send Queue│ │Bounce/FBL│ │  Analytics   │ │  │
                          │  │  │(priority)│ │ Queue    │ │  Queue       │ │  │
                          │  │  └────┬─────┘ └────┬─────┘ └──────┬───────┘ │  │
                          │  └──────────────────────────────────────────────┘  │
                          └────────────────────────┬──────────────────────────┘
                                                   │
                          ┌────────────────────────▼──────────────────────────┐
                          │            Email Provider Abstraction Layer        │
                          │  ┌────────┐ ┌──────────┐ ┌────────┐ ┌──────────┐  │
                          │  │  SES   │ │ SendGrid │ │Mailgun │ │ Postmark │  │
                          │  │Adapter │ │ Adapter  │ │Adapter │ │ Adapter  │  │
                          │  └────┬───┘ └────┬─────┘ └───┬────┘ └────┬─────┘  │
                          │  ┌────┴─────────────────────────────┴────────┐   │
                          │  │           SMTP Adapter (fallback)         │   │
                          │  └──────────────────────────────────────────┘   │
                          │  ┌──────────────────────────────────────────┐  │
                          │  │ Provider Router (failover, weighted,     │  │
                          │  │ health scoring, circuit breaker)         │  │
                          │  └──────────────────────────────────────────┘  │
                          └────────────────────────┬────────────────────────┘
                                                   │
                          ┌────────────────────────▼────────────────────────┐
                          │               Event Stream & Storage            │
                          │  ┌──────────────┐  ┌──────────┐  ┌───────────┐ │
                          │  │   Redis       │  │PostgreSQL│  │ S3 Object │ │
                          │  │   Streams     │  │(primary) │  │ Storage   │ │
                          │  └──────────────┘  └──────────┘  └───────────┘ │
                          └─────────────────────────────────────────────────┘
```

---

## 2. Component Architecture

### 2.1 Core Application (Rails API)

| Component       | Responsibility                                              |
|-----------------|--------------------------------------------------------------|
| Auth Module     | API key validation, JWT tokens, RBAC, IP allowlists          |
| Email API       | `POST /v1/emails`, `GET /v1/emails/:id`, validation, idempotency |
| Domain Manager  | SPF/DKIM/DMARC generation, DNS verification, domain tracking |
| Template Engine | ERB-based rendering, variable interpolation, versioning      |
| Webhook Dispatcher | Event delivery, signature verification, retry logic       |
| Analytics API   | Time-series aggregation, dashboard endpoints, retention      |

### 2.2 Background Workers (Sidekiq)

| Worker            | Queue          | Purpose                                      |
|-------------------|----------------|----------------------------------------------|
| EmailDispatcher   | `default`      | Validates, enqueues per-provider             |
| ProviderAdapter   | `providers`    | Sends via selected provider                  |
| BounceProcessor   | `events`       | Processes bounces / complaints               |
| WebhookDeliverer  | `webhooks`     | Delivers event callbacks                     |
| AnalyticsAggregator | `analytics` | Rolls up metrics into materialized views     |
| DomainVerifier    | `domains`      | Periodic DNS verification checks             |

### 2.3 Provider Layer

- **Adapter Pattern**: Unified `EmailProvider` interface with `send`, `cancel`, `status`
- **Provider Router**:
  - Automatic failover on 5xx / timeouts
  - Weighted routing (e.g., 70% SES primary, 30% SendGrid secondary)
  - Health scoring (exponential moving average of recent failures)
  - Circuit breaker (opens after N consecutive failures, half-open after cooldown)
  - Per-provider rate limit enforcement

### 2.4 Storage Layer

| Store       | Data                                              | Retention                          |
|-------------|---------------------------------------------------|------------------------------------|
| PostgreSQL  | Accounts, users, domains, templates, email_logs, webhook_logs, audit_logs | Indefinite (logs: 90d) |
| Redis       | Sidekiq queues, rate limit counters, sessions, cache | Configurable TTL           |
| S3          | Email body archives, attachments, exports         | 365 days                          |

---

## 3. Data Flow — Email Sending

```
Client                           Rails API                    Sidekiq                    Provider Adapter            Event Stream
  │                                 │                          │                              │                          │
  │  POST /v1/emails                │                          │                              │                          │
  │  (API Key + payload)            │                          │                              │                          │
  │────────────────────────────►    │                          │                              │                          │
  │                                 │                          │                              │                          │
  │                           ┌─────┴─────┐                    │                              │                          │
  │                           │ 1. Auth   │                    │                              │                          │
  │                           │ 2. Valid. │                    │                              │                          │
  │                           │ 3. Rate   │                    │                              │                          │
  │                           │   Limit   │                    │                              │                          │
  │                           │ 4. Idem-  │                    │                              │                          │
  │                           │   potency │                    │                              │                          │
  │                           └─────┬─────┘                    │                              │                          │
  │                                 │                          │                              │                          │
  │                           ┌─────▼─────┐                    │                              │                          │
  │                           │ 5. Persist│                    │                              │                          │
  │                           │ to PG     │                    │                              │                          │
  │                           │ status:   │                    │                              │                          │
  │                           │ queued    │                    │                              │                          │
  │                           └─────┬─────┘                    │                              │                          │
  │                                 │                          │                              │                          │
  │       201 { id, status }        │                          │                              │                          │
  │◄────────────────────────────    │                          │                              │                          │
  │                                 │                          │                              │                          │
  │                                 │  Enqueue EmailDispatch   │                              │                          │
  │                                 │─────────────────────────►│                              │                          │
  │                                 │                          │                              │                          │
  │                                 │               ┌──────────┴──────────┐                   │                          │
  │                                 │               │ Select provider    │                   │                          │
  │                                 │               │ via router rules   │                   │                          │
  │                                 │               └──────────┬──────────┘                   │                          │
  │                                 │                          │                              │                          │
  │                                 │               ┌──────────▼──────────┐                   │                          │
  │                                 │               │ Enqueue Provider    │                   │                          │
  │                                 │               │ Adapter worker      │                   │                          │
  │                                 │               └──────────┬──────────┘                   │                          │
  │                                 │                          │                              │                          │
  │                                 │                          │   provider_adapter.perform    │                          │
  │                                 │                          │──────────────────────────────►│                          │
  │                                 │                          │                              │                          │
  │                                 │                          │                    ┌──────────┴──────────┐               │
  │                                 │                          │                    │ Send via HTTP/SMTP  │               │
  │                                 │                          │                    │ Track response     │               │
  │                                 │                          │                    └──────────┬──────────┘               │
  │                                 │                          │                              │                          │
  │                                 │                          │                    ┌──────────▼──────────┐               │
  │                                 │                          │                    │ Record result      │               │
  │                                 │                          │                    │ (sent / failed)    │               │
  │                                 │                          │                    └──────────┬──────────┘               │
  │                                 │                          │                              │                          │
  │                                 │                          │                    Publish delivery.stream             │
  │                                 │                          │                              │─────────────────────────►│
  │                                 │                          │                              │                          │
  │                                 │                          │                              │     ┌────────────────────┴─────┐
  │                                 │                          │                              │     │ Consumer:              │
  │                                 │                          │                              │     │ - update email_log    │
  │                                 │                          │                              │     │ - enqueue webhook     │
  │                                 │                          │                              │     │ - update analytics    │
  │                                 │                          │                              │     └──────────────────────────┘
```

---

## 4. Key Design Decisions & Tradeoffs

### 4.1 Monolith-first, not microservices

**Decision**: Start with a single Rails API app + Sidekiq workers.  
**Rationale**: A monolith reduces operational complexity, simplifies transactions, and avoids distributed debugging overhead. The bounded context (email processing) has clear async boundaries via queues, making future extraction into services straightforward.  
**Tradeoff**: Deployment scaling is less granular. Mitigated by horizontally scaling web + workers independently.

### 4.2 Redis Streams for events (not Kafka)

**Decision**: Use Redis Streams with a pluggable `EventStream` abstraction.  
**Rationale**: Redis is already required for Sidekiq. Streams provide consumer groups, message acknowledgment, and at-least-once delivery. Kafka would add operational overhead (ZooKeeper, brokers) with no immediate benefit at expected volume.  
**Tradeoff**: Redis Streams have lower throughput and limited long-term retention. The abstraction allows swapping to Kafka later.

### 4.3 PostgreSQL as primary store (not DynamoDB/Cassandra)

**Decision**: Use PostgreSQL with partitioning and materialized views.  
**Rationale**: Relational integrity across accounts, domains, templates, and billing. Time-series analytics use partitioned tables and materialized aggregation views.  
**Tradeoff**: Write throughput is lower than NoSQL. Mitigated by batch inserts, connection pooling (PgBouncer), and read replicas for analytics queries.

### 4.4 Provider adapter with circuit breaker

**Decision**: Each provider wraps an HTTP client with circuit breaker (via `semian` or custom `circuitbox`).  
**Rationale**: Prevents cascading failures when a provider degrades. Health scoring enables weighted routing away from unhealthy providers.  
**Tradeoff**: Added latency from circuit state checks (~microseconds). Provider failover means eventual consistency on delivery status.

---

## 5. Scaling Model

```
                  ┌─────────────┐
                  │   Route53   │
                  └──────┬──────┘
                         │
                  ┌──────▼──────┐
                  │    ALB      │
                  │ (SSL term)  │
                  └──┬──────┬───┘
                     │      │
              ┌──────▼┐ ┌───▼──────┐
              │ Web   │ │ Web      │  ← horizontal scaling (auto-scaling group)
              │ (n)   │ │ (n+1)    │
              └───┬───┘ └───┬──────┘
                  │         │
          ┌───────▼─────────▼───────┐
          │   PostgreSQL (primary)   │
          │   + read replicas        │
          └───────┬─────────────────┘
                  │
          ┌───────▼─────────────────┐
          │   Redis / Sidekiq       │
          │   (ElastiCache / self)  │
          └───────┬─────────────────┘
                  │
          ┌───────▼─────────────────┐
          │   S3 (email storage)    │
          └─────────────────────────┘
```

- **Web tier**: Scales via ALB target group. Stateless — all session data in Redis.
- **Worker tier**: Scales independently via queue depth (Sidekiq).
- **Database**: Primary for writes, read replicas for analytics dashboard.
- **Redis**: Cluster mode for high availability.

---

## 6. Observability Stack

| Concern           | Tool                             |
|-------------------|----------------------------------|
| Structured logs   | `lograge` + JSON to stdout       |
| Metrics           | `prometheus_exporter` + Grafana  |
| Distributed traces| OpenTelemetry (Jaeger exporter)  |
| Health checks     | `/health` (liveness + readiness) |
| Error tracking    | Sentry                           |

- Every email send produces a trace spanning API → Sidekiq → Provider → DB.
- Key dashboards: delivery rate, error budget, queue depth, provider latency.

---

## 7. Security Posture

- **API Keys**: Hashed with `bcrypt`; prefix stored for identification
- **JWT**: RS256 with short-lived access tokens (15min), refresh tokens (7d)
- **RBAC**: Roles per organization (owner, admin, developer, read-only)
- **Encryption at rest**: PostgreSQL TDE + S3 server-side encryption
- **Encryption in transit**: TLS 1.3 everywhere
- **Audit logs**: Immutable log of all mutating API calls (who, what, when, IP)
- **Rate limiting**: Per API key (sliding window via Redis), per IP (connection-level)

---

This concludes Phase 1. Shall I proceed to **Phase 2 — Rails Project Structure**?
