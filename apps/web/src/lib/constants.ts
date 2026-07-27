export const API_BASE = process.env.NEXT_PUBLIC_API_URL || "/api/v1";

export const SCOPES = [
  { id: "email:send", label: "Send emails" },
  { id: "email:read", label: "Read emails" },
  { id: "template:manage", label: "Manage templates" },
  { id: "domain:read", label: "Read domains" },
  { id: "domain:write", label: "Manage domains" },
  { id: "webhook:manage", label: "Manage webhooks" },
  { id: "api_key:manage", label: "Manage API keys" },
  { id: "analytics:read", label: "View analytics" },
];

export const SCOPE_IDS = SCOPES.map((s) => s.id);

export const EMAIL_STATUSES = ["queued", "sending", "delivered", "bounced", "opened", "clicked", "complained"] as const;

export const WEBHOOK_EVENTS = [
  "email.delivered",
  "email.bounced",
  "email.opened",
  "email.clicked",
  "email.complained",
  "email.sent",
] as const;

export const PER_PAGE_DEFAULT = 20;

export const RATE_LIMIT_THRESHOLD = 0.8;

export const MONTHLY_EMAIL_LIMIT_DEFAULT = 100000;
