# Email Service — Feature Roadmap

Goal: Feature parity with SendByte.africa + production readiness.

---

## ✅ Already Implemented

| Feature | Status |
|---------|--------|
| REST API (Fastify, typed routes) | Done |
| Auth: login / refresh / logout (JWT + bcrypt) | Done |
| API Keys: create, list, revoke (scoped) | Done |
| Domains: register, SPF/DKIM/DMARC verification | Done (DNS check via job) |
| Templates: create, versioning, render with variables, send | Done |
| Emails: send, batch send, list, get by ID, validate | Done |
| Webhooks: create, list, delete, delivery tracking | Done |
| Analytics: overview, per-provider, activity, usage | Done |
| Dashboard: usage charts, activity feed, alerts | Done |
| Database: 32 tables, full FK/indexes, Kysely migrations | Done |
| Workers: email-processor, delivery-processor, webhook-processor, analytics-processor, scheduled | Done |
| Domain services (6 packages) | Done |
| Idempotency keys | Done |
| Rate limiting | Done |
| Request validation (Zod) | Done |
| IP allowlisting on API keys | Done |
| Pagination | Done (offset-based) |

---

## ❌ Gap Analysis vs SendByte

### Phase 1 — Core API Maturity  (Priority: High)

**1a. Suppressions / Bounce Handling**
- DB table exists (`delivery_events`) but no suppression list
- Add `/v1/suppressions` GET, POST, DELETE endpoints
- Auto-suppress on hard bounce + complaint
- Self-service removal via verified email
- DB migration: `suppressions` table with `email`, `reason`, `organization_id`, `created_at`
- Domain service: `SuppressionService`

**1b. Attachments**
- DB schema: `attachments` table exists and is wired to `email_messages`
- Route handler: add `multipart/form-data` upload support to `POST /v1/emails`
- Store in S3-compatible storage, reference by ID in the send payload

**1c. Cursor-based Pagination**
- Current: offset-based (`page`, `perPage`)
- Add cursor-based (`after`, `limit`) to email list, webhook delivery list
- More efficient for large datasets; match SendByte's API

**1d. Scheduled Sending**
- DB: `scheduled_at` column already exists on `email_messages`
- Worker: `scheduled` worker package exists, ensure it picks up scheduled emails
- Route: accept `scheduledAt` in `POST /v1/emails`
- Add `/v1/emails/{id}/cancel` to cancel a scheduled send

**1e. Single-Recipient Batch Normalization**
- SendByte accepts `to` as string or array (up to 50)
- We have this already; ensure consistent response shape

### Phase 2 — Open / Click Tracking  (Priority: High)

**2a. Tracking Pixel (Open Tracking)**
- DB: `email_metrics` table exists
- Add route `GET /track/open/{messageId}.png` — transparent 1x1 pixel, records open event
- Worker: inject pixel at send time (append to HTML body)
- Update `email_metrics` open_count, opened_at, is_opened

**2b. Click Tracking**
- DB: already supports via `email_metrics`
- Add route `GET /track/click/{messageId}?redirect={encodedUrl}` — redirects after recording click
- Worker: rewrite all `<a href>` links in HTML before sending
- Update `email_metrics` click_count, clicked_at, is_clicked

**2c. Tracking Domain**
- DB: `domains.tracking_domain` column exists
- Worker: rewrite tracking pixel/click URLs to use custom tracking domain
- Add DNS record helper for CNAME setup

### Phase 3 — Sandbox Mode  (Priority: High)

**3a. `sk_test_` API Keys**
- Key prefix: detect `sk_test_` vs `sk_live_`
- Sandbox keys skip real delivery, store email as "sent" with simulated events
- Worker/processor: check key type, emit fake event sequence (sent → delivered → opened → clicked)
- UI: show sandbox badge / filter in dashboard

**3b. Simulated Event Timeline**
- Auto-generate webhook calls for sandbox emails
- Show full event timeline in email detail UI (same as live, but simulated)
- No domain verification required for sandbox

### Phase 4 — Signed Webhooks  (Priority: High)

**4a. HMAC-SHA256 Signatures**
- Already have `generateWebhookSignature` / `verifyWebhookSignature` in crypto package
- Worker: sign each webhook payload with the endpoint's secret
- Include `X-SendByte-Signature` header (or `X-Email-Service-Signature`)
- Docs: consumer verification guide

**4b. Webhook Secret Rotation**
- Add `POST /v1/webhooks/{id}/rotate-secret` endpoint
- DB: `webhooks.secret_ciphertext` already stores encrypted secret
- Service method to rotate and re-encrypt

**4c. Webhook Replay**
- Add `POST /v1/webhooks/{id}/replay/{deliveryId}` endpoint
- UI: replay button next to failed deliveries
- Worker: re-queues the webhook payload

**4d. Webhook Event Types**
- Currently we emit events; formalize event type enum matching SendByte:
  - `email.sent`, `email.delivered`, `email.bounced`, `email.opened`, `email.clicked`, `email.complained`
- Domain verification events: `domain.verified`, `domain.failed`

### Phase 5 — SMTP Gateway  (Priority: High)

**5a. SMTP Server**
- New package: `packages/gateways/smtp/`
- Use `smtp-server` (Node.js) to listen on ports 587, 465, 2525
- Authenticate via `AUTH PLAIN` / `AUTH LOGIN` using API key (password field)
- Parse the email, extract from/to/subject/body/attachments
- Push into the same send pipeline (queue a job)
- STARTTLS + TLS support

**5b. SMTP Credentials in UI**
- Show SMTP server host, port, TLS settings in dashboard
- Username = API key ID, Password = API key secret

### Phase 6 — Billing  (Priority: High for production)

**6a. Plan & Quota System**
- DB: `plans` table (name, monthly_email_limit, price_cents, features jsonb)
- DB: `subscriptions` table (organization_id, plan_id, status, period_start, period_end)
- Meter: increment `organizations.emails_sent_this_month` on each send
- Middleware: check quota before accepting send; reject with 429 if exceeded

**6b. Pay-as-You-Go Overage**
- After quota exhausted, allow overage at fixed per-email rate
- Record in `usage_records` table (already exists)
- Generate overage invoice at end of billing period

**6c. Invoice Collection**
- Paystack / Flutterwave integration for Naira collection
- Webhook handler for payment success/failure
- Auto-suspend on failed payment after grace period

### Phase 7 — SDKs  (Priority: Medium)

**7a. Node.js SDK (`@resendbyte/node`)**
- New package: `packages/sdks/node/`
- Zero dependencies, full TypeScript
- Methods: `emails.send()`, `emails.list()`, `emails.get()`, `domains.*`, `templates.*`, `webhooks.*`
- Publish to npm

**7b. Community SDKs**
- Python: `pip install resendbyte`
- Go: `go get github.com/.../resendbyte-go`
- PHP: `composer require resendbyte/php`
- Rust: community-maintained

### Phase 8 — MCP Server  (Priority: Medium)

**8a. Model Context Protocol Server**
- New package: `packages/tools/mcp/`
- Exposes tools: `send_email`, `list_emails`, `get_email`, `create_domain`, `verify_domain`, `list_templates`
- AI agents (Claude, Cursor, etc.) can send email directly
- Follow SendByte's lead on this

### Phase 9 — UI Polish  (Priority: Medium)

**9a. Email Detail Page with Event Timeline**
- Current: basic detail page
- Add: visual timeline (sent → delivered → opened → clicked) with timestamps
- SMTP trace viewer (raw MIME, delivery logs)

**9b. Webhook Replay UI**
- List webhook deliveries with status badges
- Replay button on failed deliveries
- Request/response inspector

**9c. Sandbox / Live Toggle**
- Global filter to switch between sandbox and live keys
- Badge on each email showing environment
- Separate counts/dashboard

### Phase 10 — Production Hardening  (Priority: Medium)

**10a. Rate Limiting Tiers**
- Current: global rate limit
- Add per-organization tiers based on plan
- Add per-endpoint rate limits (e.g., auth: 10/min, email: 1000/min)

**10b. Audit Trails**
- DB: `audit_logs` table exists
- Service decorator: log all mutating operations (create API key, delete webhook, etc.)

**10c. Observability**
- Current: OpenTelemetry, Sentry, Prometheus configured
- Add: structured logging per-request, dashboard metrics, SLO tracking

---

## Implementation Order

```
Phase 1 → Phase 2 → Phase 3 → Phase 4
                            ↓
                       Phase 5 → Phase 6
                            ↓
                       Phase 7 → Phase 8 → Phase 9 → Phase 10
```

Phases within each tier can be worked in parallel where dependencies allow.
