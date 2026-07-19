# Email Service Platform - TypeScript Migration

A production-grade transactional email delivery platform migrated from Ruby on Rails to TypeScript/Node.js.

## Architecture

```
email-service/
├── packages/
│   ├── config/          # Environment configuration (Zod)
│   ├── types/           # Shared types, branded IDs, schemas
│   ├── errors/          # Application error hierarchy
│   ├── logger/          # Structured logging (Pino)
│   ├── crypto/          # JWT, API keys, passwords, encryption
│   ├── queue/           # Background jobs (BullMQ)
│   ├── telemetry/       # OpenTelemetry, metrics, tracing
│   ├── database/        # Kysely + PostgreSQL, migrations, repositories
│   ├── domain/
│   │   ├── auth/        # Authentication, tokens, API keys
│   │   ├── email/       # Email pipeline, providers, validation
│   │   ├── templates/   # Template engine, versioning
│   │   ├── domains/     # DNS, verification, DKIM/SPF/DMARC
│   │   ├── analytics/   # Rollups, aggregates, metrics
│   │   ├── webhooks/    # Delivery, retry, signatures
│   │   └── billing/     # Quotas, usage, costs
│   ├── api/
│   │   ├── server/      # Fastify app, routes, plugins
│   │   ├── middleware/  # Auth, rate-limit, validation
│   │   ├── routes/      # Feature-flagged route modules
│   │   └── openapi/     # Spec generation, validation
│   └── workers/
│       ├── email-processor/
│       ├── delivery-processor/
│       ├── analytics-processor/
│       ├── webhook-processor/
│       └── scheduled/
├── apps/
│   ├── api/             # Main API server (Fastify)
│   └── cli/             # Migration, admin commands
└── tools/
    ├── migrate/
    ├── benchmark/
    └── chaos/
```

## Quick Start

### Prerequisites
- Node.js 20+
- pnpm 9+
- Docker & Docker Compose
- PostgreSQL 16+ (or use Docker)

### Development Setup

```bash
# Install dependencies
pnpm install

# Start infrastructure
pnpm docker:up

# Run migrations
pnpm db:migrate

# Seed development data
pnpm db:seed

# Start development servers
pnpm dev
```

### Environment Variables

```bash
# Copy and edit
cp .env.example .env

# Required variables
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/email_service
REDIS_URL=redis://localhost:6379
JWT_SECRET=your-super-secret-key-at-least-32-chars
NODE_ENV=development
```

### Running Tests

```bash
# Unit tests
pnpm test

# With coverage
pnpm test:coverage

# Type checking
pnpm typecheck

# Linting
pnpm lint
```

## API Endpoints

### Authentication
```
POST   /api/v1/auth/login           # Email/password login
POST   /api/v1/auth/refresh         # Refresh access token
POST   /api/v1/auth/logout          # Logout (revoke refresh token)
```

### Emails
```
POST   /api/v1/emails               # Send single email
POST   /api/v1/emails/batch         # Send batch emails
POST   /api/v1/emails/validate      # Validate email params
GET    /api/v1/emails/:id           # Get email status
GET    /api/v1/emails               # List emails (paginated)
```

### Templates
```
POST   /api/v1/templates            # Create template
GET    /api/v1/templates            # List templates
GET    /api/v1/templates/:id        # Get template
POST   /api/v1/templates/:id/send   # Send template email
```

### Domains
```
POST   /api/v1/domains              # Add domain
GET    /api/v1/domains              # List domains
POST   /api/v1/domains/:id/verify   # Verify DNS records
DELETE /api/v1/domains/:id          # Delete domain
```

### Analytics
```
GET    /api/v1/analytics/overview   # Overview metrics
GET    /api/v1/analytics/deliverability  # Delivery rates
GET    /api/v1/analytics/engagement     # Open/click rates
```

### Webhooks
```
POST   /api/v1/webhooks             # Register webhook
GET    /api/v1/webhooks             # List webhooks
DELETE /api/v1/webhooks/:id         # Delete webhook
```

## API Key Authentication

Use Bearer token in Authorization header:

```bash
curl -H "Authorization: Bearer em_dev_xxxxxxxxxxxxx" \
     http://localhost:3000/api/v1/emails
```

## Background Jobs

Workers run as separate processes:

```bash
# Email processing
pnpm --filter=@email-service/workers-email-processor dev

# Delivery processing
pnpm --filter=@email-service/workers-delivery-processor dev

# Analytics rollups
pnpm --filter=@email-service/workers-analytics-processor dev
```

## Database Migrations

```bash
# Generate new migration
pnpm --filter=@email-service/database db:generate --name "add_new_table"

# Run migrations
pnpm db:migrate

# Rollback last migration
pnpm db:rollback
```

## Observability

- **Metrics**: Prometheus at `:9090`, Grafana at `:3000` (admin/admin)
- **Tracing**: Jaeger at `:16686`
- **Logs**: Structured JSON via Pino

## Deployment

```bash
# Build all packages
pnpm build

# Build Docker image
docker build -t email-service:latest .

# Run production
docker compose -f docker-compose.prod.yml up -d
```

## Project Structure Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Runtime | Node.js 20 LTS | Long-term support, native fetch |
| Framework | Fastify | Performance, TypeScript-first |
| Database | Kysely + PostgreSQL | Type-safe SQL, no ORM overhead |
| Queue | BullMQ | Redis-backed, priority, delayed jobs |
| Validation | Zod | Runtime + compile-time types |
| Logging | Pino | Fast, structured, child loggers |
| Testing | Vitest | Fast, ESM native, coverage |
| Build | Turborepo | Monorepo, caching, parallelization |

## Migration

The migration from Ruby on Rails to TypeScript/Node.js is complete.
See [MIGRATION_PLAN.md](./MIGRATION_PLAN.md) for the full migration record.

## License

MIT