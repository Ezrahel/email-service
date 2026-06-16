# Database Schema Design

## 1. Entity Relationship Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                         ORGANIZATIONS                                │
│  organizations ──1:N── memberships ──N:1── users                    │
│       │                                                             │
│       ├──1:N── teams                                                │
│       ├──1:N── api_keys                                             │
│       ├──1:N── domains                                              │
│       ├──1:N── templates ──1:N── template_versions                  │
│       ├──1:N── email_messages ──1:N── deliveries                    │
│       │       │                       │                             │
│       │       ├──1:N── attachments    ├──1:N── provider_attempts    │
│       │       │                       │                             │
│       │       └──1:N── recipients     └──1:N── delivery_events     │
│       │                                                             │
│       ├──1:N── webhooks ──1:N── webhook_deliveries                 │
│       ├──1:N── usage_records                                        │
│       └──1:N── audit_logs                                           │
│                                                                     │
│  users ──N:1── roles (through memberships)                          │
└─────────────────────────────────────────────────────────────────────┘
```

### Entity Summary

| Entity | Module | Volume | Retention | Partitioned |
|--------|--------|--------|-----------|-------------|
| organizations | Identity | Low | Indefinite | No |
| users | Identity | Low | Indefinite | No |
| memberships | Identity | Low | Indefinite | No |
| teams | Identity | Low | Indefinite | No |
| roles | Identity | Very Low | Indefinite | No |
| api_keys | Identity | Low | Indefinite | No |
| domains | Identity | Low | Indefinite | No |
| dns_records | Identity | Low | Indefinite | No |
| templates | Email | Low | Indefinite | No |
| template_versions | Email | Low | Indefinite | No |
| email_messages | Email | Very High | 90 days | Yes (monthly) |
| recipients | Email | High | 90 days | Yes (monthly) |
| attachments | Email | Medium | 90 days | No (S3-backed) |
| deliveries | Delivery | High | 90 days | Yes (monthly) |
| provider_attempts | Delivery | Very High | 30 days | Yes (daily) |
| delivery_events | Delivery | Very High | 90 days | Yes (monthly) |
| webhooks | Infrastructure | Low | Indefinite | No |
| webhook_deliveries | Infrastructure | High | 30 days | Yes (monthly) |
| email_metrics | Analytics | Low | Indefinite | No |
| aggregates | Analytics | Medium | 1 year | Yes (monthly) |
| event_logs | Analytics | Very High | 30 days | Yes (daily) |
| audit_logs | Infrastructure | Medium | 1 year | Yes (monthly) |
| jobs | Infrastructure | Medium | 30 days | Yes (monthly) |
| usage_records | Billing | Medium | 1 year | Yes (monthly) |

## 2. Key Design Decisions

### UUID Primary Keys
- All tables use UUID primary keys (via `gen_random_uuid()`)
- Avoids sequential ID enumeration attacks
- Simplifies distributed ID generation across shards
- Tradeoff: 16 bytes vs 4/8 bytes for integer; index size 20-30% larger
- Mitigated by modern storage + covering indexes

### Partitioning by Range (created_at)
- High-volume tables partitioned monthly or daily
- Enables efficient time-range queries
- Allows DROP PARTITION for instant retention enforcement
- Avoids DELETE bloat and VACUUM pressure

### JSONB for Flexible Fields
- `headers`, `tags`, `metadata` use JSONB
- Indexed with GIN for key/value lookups when needed
- Avoids schema migrations for user-defined fields

### organization_id Everywhere
- Every resource table has `organization_id` as a FK
- Application-layer scoping via `default_scope { where(organization_id: Current.organization_id) }`
- No Row-Level Security — application-level scoping is sufficient and more portable

### Soft Deletes
- Soft deletes via `deleted_at` timestamp on user-facing entities
- Hard deletes + partition drop for high-volume event data
- `acts_as_paranoid` or manual `where(deleted_at: nil)` scoping

## 3. Column Naming Conventions

| Pattern | Example | Description |
|---------|---------|-------------|
| `_id` suffix | `organization_id` | Foreign key (UUID) |
| `_at` suffix | `created_at`, `verified_at` | Timestamps |
| `_count` suffix | `delivery_count` | Counter cache |
| `_type` suffix | `recipient_type` | Enum/string discriminator |
| `_key` suffix | `idempotency_key` | Business key |
| `_bytes` suffix | `html_body_bytes` | Size in bytes |
| `is_` prefix | `is_verified`, `is_primary` | Boolean flags |

## 4. Index Strategy

### B-tree Indexes (default)
- All foreign keys (`organization_id`, `user_id`, etc.)
- Status enums with selective cardinality (filtered indexes where possible)
- `created_at DESC` for recent-record queries
- Composite indexes for common query patterns:
  - `(organization_id, created_at DESC)` on email_messages
  - `(email_message_id, event_type, created_at)` on delivery_events
  - `(organization_id, status, created_at DESC)` on email_messages

### Partial Indexes
- `WHERE deleted_at IS NULL` on soft-deletable tables
- `WHERE status IN ('failed', 'bounced')` for retry workers
- `WHERE processed_at IS NULL` for unprocessed events

### GIN Indexes
- `ON email_messages USING GIN (tags)` for tag-based queries
- `ON email_messages USING GIN (headers jsonb_path_ops)` for header lookups

### BRIN Indexes
- On partitioned tables where created_at range scans are common
- Much smaller than B-tree for append-heavy tables
- `ON delivery_events USING BRIN (created_at)` with `pages_per_range = 32`

## 5. Multi-Tenancy Architecture

### Isolation Level: Application-Level Scoping

```ruby
# In ApplicationRecord or concern
module TenantScoped
  extend ActiveSupport::Concern

  included do
    default_scope -> {
      if Current.organization_id
        where(organization_id: Current.organization_id)
      end
    }
  end
end
```

### Scoping Rules
- All tenant-scoped resources accessed through `current_organization`
- Cross-organization access only through explicit admin routes
- API keys scoped to organization; validate on every request
- Usage quotas computed per organization

### Authorization Boundary
- Organization owns everything
- Users access resources through memberships
- Roles determine action permissions within org
- API keys inherit permissions of the associated user/role
