# Mailo — Web & Dashboard UI Design

## Design System

### Color Palette

| Token | Value | Usage |
|-------|-------|-------|
| `--bg` | `#f5f5f7` | Page background |
| `--surface` | `rgba(255, 255, 255, 0.72)` | Glass card backgrounds |
| `--surface-border` | `rgba(255, 255, 255, 0.4)` | Glass card borders |
| `--surface-shadow` | `0 8px 32px rgba(0, 0, 0, 0.06)` | Glass card shadow |
| `--accent` | `#333` | Primary accent (buttons, links, active states) |
| `--accent-hover` | `#1a1a1a` | Accent hover |
| `--accent-glass` | `rgba(51, 51, 51, 0.08)` | Accent on glass surfaces |
| `--text-primary` | `#1d1d1f` | Headings / body text |
| `--text-secondary` | `#6e6e73` | Labels, descriptions |
| `--text-tertiary` | `#86868b` | Placeholder, disabled |
| `--success` | `#30d158` | Delivered, verified, active |
| `--warning` | `#ff9f0a` | Pending, rate-limited |
| `--danger` | `#ff453a` | Bounced, failed, revoked |
| `--chart-1` | `#333` | Primary chart series |
| `--chart-2` | `#86868b` | Secondary chart series |
| `--chart-3` | `#30d158` | Positive metric series |
| `--chart-4` | `#ff453a` | Negative metric series |

### Glass Morphism

```css
.glass {
  background: var(--color-surface);
  backdrop-filter: blur(20px);
  border: 1px solid var(--color-surface-border);
  border-radius: 16px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.06);
}
```

Variants: `glass-sm` (blur 12px, radius 10px), `glass-lg` (blur 32px, radius 20px). `input-glass` for form inputs.

### Typography

- **Font stack**: `-apple-system, BlinkMacSystemFont, "SF Pro Display", "SF Pro Text", "Helvetica Neue", Helvetica, Arial, sans-serif`
- **Mono**: `"SF Mono", "Fira Code", "Fira Mono", "Roboto Mono", monospace`
- **Scale**: 11 / 13 / 15 / 17 / 20 / 24 / 28 / 34 / 48 px
- **Weights**: 400 (regular), 500 (medium), 600 (semibold), 700 (bold)

---

## Pages

### 1. Login (`/login`)
- Centered single column, no sidebar
- Glass card: "Mailo" logo, "Sign in to your email dashboard" subtitle
- Email input, password input, "Sign In" button
- States: idle → loading (button spinner) → success (redirect) → error (inline message)
- Calls `POST /auth/login`, stores token in localStorage

### 2. Dashboard (`/dashboard`)
- 4 stat cards: Sent, Delivered, Bounce Rate, Open Rate (fetched from `/analytics/overview` + `/dashboard/usage`)
- ActivityChart (Recharts AreaChart — 30-day volume from `/dashboard/activity`)
- ProviderBreakdownChart (Recharts PieChart donut — from `/dashboard/providers`)
- RecentActivityTable (compact, scrollable)
- AlertsPanel (from `/dashboard/alerts` — shows "No alerts — all clear")
- States: loading (skeletons) → loaded → error (retry per card) → empty (first-run welcome)

### 3. Emails List (`/emails`)
- Search input + status filter dropdown
- Paginated table: To, Subject, Status (badge with dot), Sent (relative time)
- Row click → `/emails/{id}`
- "+ Compose" button → `/emails/new`
- States: loading (skeleton rows) → empty (EmptyState) → loaded → error (retry)

### 4. Compose Email (`/emails/new`)
- Form in glass card: From, To (comma-separated for batch), Subject, Reply-To, Tags, HTML body (textarea 12 rows), Text fallback (textarea 6 rows)
- Actions: Send (primary), Send Batch (secondary), Validate (ghost)
- Calls `POST /emails` (single or batch) or `POST /emails/validate`
- States: idle → validating → sending (spinner, inputs disabled) → success (redirect to detail) → error (toast)

### 5. Email Detail (`/emails/{id}`)
- Status badge (large with icon), metadata glass card (from, to, subject, sent, tags)
- Delivery Timeline: horizontal stepper — Queued → Sending → Delivered
- Delivery Details glass card: provider, attempts, response code
- Preview: tabs for HTML Preview (iframe) and Plain Text (pre)
- States: loading (skeleton) → loaded → not found

### 6. Templates List (`/templates`)
- Paginated table: Name, Slug, Created date
- Row click → `/templates/{id}`
- "+ Create" button → `/templates/new`

### 7. Create Template (`/templates/new`)
- Glass form: Name, Subject, HTML Body, Text fallback
- Calls `POST /templates`
- States: idle → saving → success (redirect to detail) → error (toast)

### 8. Template Detail (`/templates/{id}`)
- Name, slug, created date
- "Send from this template" → opens Modal with To input + Variables key-value editor (extracts `{{var}}` from template)
- Modal calls `POST /templates/{id}/send`

### 9. Domains (`/domains`)
- Expandable glass cards per domain
- Expanded: DNS record instructions (SPF, DKIM, DMARC) each with CopyButton and verification status
- "Verify" button on each card → `POST /domains/{id}/verify`
- "+ Add Domain" → Modal with domain input → `POST /domains`
- Status badges: Verified (green), Pending (orange), Failed (red)

### 10. Webhooks (`/webhooks`)
- Glass cards: URL, status badge, event pills, created date, delete button
- "+ Create Webhook" → Modal: URL input, event selection (toggle buttons), optional secret
- Delete: confirmation Dialog (danger variant)
- Calls: `GET /webhooks`, `POST /webhooks`, `DELETE /webhooks/{id}`

### 11. API Keys (`/api-keys`)
- Glass cards: name, masked key (`prefix****lastChars`), status badge, scope pills, created/last used, revoke button
- "+ Create Key" → Two-step Modal:
  - Step 1: Name, scope toggles, optional expiry
  - Step 2: Full key revealed once with CopyButton + warning
- Revoke: confirmation Dialog (danger variant)

---

## Shared Components

| Component | File | Description |
|-----------|------|-------------|
| Button | `components/ui/Button.tsx` | Primary/secondary/ghost/danger, sizes sm/md/lg, loading spinner |
| Input | `components/ui/Input.tsx` | Glass input, label, error, hint |
| Badge | `components/ui/Badge.tsx` | Colored pill with optional dot |
| Skeleton | `components/ui/Skeleton.tsx` | Animated pulse placeholder, count prop |
| Modal | `components/ui/Modal.tsx` | Portal glass dialog, backdrop overlay, Esc/click-outside close |
| Dialog | `components/ui/Dialog.tsx` | Confirmation modal, danger variant |
| Table | `components/ui/Table.tsx` | Sortable columns, glass header, row click |
| Pagination | `components/ui/Pagination.tsx` | Pages with ellipsis, prev/next |
| Tabs | `components/ui/Tabs.tsx` | Underline-style tabs |
| EmptyState | `components/ui/EmptyState.tsx` | Icon + heading + description + action |
| CopyButton | `components/ui/CopyButton.tsx` | Copy/check icon toggle |
| Select | `components/ui/Select.tsx` | Glass dropdown, matches Input styling |
| Toast | `components/ui/Toast.tsx` | Provider + hook, 4 types, auto-dismiss |

---

## Layout

```
┌──────────────────────────────────────────────┐
│  ┌──────┐  ┌──────────────────────────────┐  │
│  │      │  │  Dashboard  ›  Emails        │  │
│  │  S   │  ├──────────────────────────────┤  │
│  │  I   │  │                              │  │
│  │  D   │  │        Page Content          │  │
│  │  E   │  │        (max-w 1400px)        │  │
│  │  B   │  │                              │  │
│  │  A   │  │                              │  │
│  │  R   │  └──────────────────────────────┘  │
│  │      │                                    │
│  └──────┘                                    │
└──────────────────────────────────────────────┘
```

- **Sidebar**: Glass panel, collapsible. Nav: Dashboard, Emails, Templates, Domains, Webhooks, API Keys. Active route highlighted. "Mailo" brand at top.
- **TopBar**: Breadcrumb (auto-generated from pathname), user avatar dropdown with "Sign Out".
- **AuthGuard**: Checks localStorage token, redirects to `/login` if missing.

---

## Tech Stack

| Layer | Choice |
|-------|--------|
| Framework | Next.js 16 (App Router) |
| Language | TypeScript (strict) |
| Styling | Tailwind CSS v4 |
| Charts | Recharts |
| Icons | Lucide React |
| HTTP | Native `fetch` |

## API Integration

All calls go through `lib/api.ts` wrapper:
- Attaches `Bearer` token from localStorage
- Handles 401 → clears token
- Exposes `api.get<T>()`, `api.post<T>()`, `api.delete<T>()`
- Base URL: `NEXT_PUBLIC_API_URL` or `http://localhost:3000/api/v1`

## Responsive

- Mobile (< 768px): single column, sidebar as hamburger drawer
- Tablet (768-1024px): collapsed sidebar (icons only)
- Desktop (> 1024px): full sidebar + content grid

## Routes

| Path | Page | Auth |
|------|------|------|
| `/` | Redirect → /dashboard | No |
| `/login` | Login | No |
| `/dashboard` | Dashboard | Yes |
| `/emails` | Email list | Yes |
| `/emails/new` | Compose | Yes |
| `/emails/[id]` | Email detail | Yes |
| `/templates` | Template list | Yes |
| `/templates/new` | Create template | Yes |
| `/templates/[id]` | Template detail | Yes |
| `/domains` | Domains with DNS | Yes |
| `/webhooks` | Webhooks | Yes |
| `/api-keys` | API Keys | Yes |
