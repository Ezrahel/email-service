import type { Metadata } from "next";
import { DocsPageNav } from "../DocsPageNav";

export const metadata: Metadata = {
  title: "API Reference — Mailo Docs",
  description: "Complete API reference for the Mailo transactional email platform. All REST endpoints, request/response schemas, and examples.",
  openGraph: { title: "API Reference — Mailo Docs" },
};

const endpoints = [
  {
    method: "POST",
    path: "/api/v1/auth/login",
    scopes: "none",
    description: "Log in with email and password to receive JWT tokens.",
    body: [
      { field: "email", type: "string", required: true, description: "Account email address" },
      { field: "password", type: "string (8-128)", required: true, description: "Account password" },
    ],
  },
  {
    method: "POST",
    path: "/api/v1/auth/refresh",
    scopes: "none",
    description: "Exchange a refresh token for a new access token.",
    body: [
      { field: "refreshToken", type: "string", required: true, description: "Refresh token from login" },
    ],
  },
  {
    method: "POST",
    path: "/api/v1/auth/logout",
    scopes: "none",
    description: "Log out the current session.",
  },
  {
    method: "GET",
    path: "/api/v1/api-keys",
    scopes: "api_key:read",
    description: "List all API keys for the organization.",
  },
  {
    method: "POST",
    path: "/api/v1/api-keys",
    scopes: "api_key:write",
    description: "Create a new API key.",
    body: [
      { field: "name", type: "string (1-255)", required: true, description: "Human-readable key name" },
      { field: "scopes", type: "string[]", required: false, description: "Key scopes (defaults to all)" },
      { field: "expiresAt", type: "string (ISO 8601)", required: false, description: "Key expiration timestamp" },
      { field: "allowedIPs", type: "string[]", required: false, description: "IP allowlist for this key" },
      { field: "environment", type: "live | sandbox", required: false, description: "Key environment (sandbox simulates sends)" },
    ],
  },
  {
    method: "DELETE",
    path: "/api/v1/api-keys/:id",
    scopes: "api_key:write",
    description: "Revoke (delete) an API key.",
  },
  {
    method: "POST",
    path: "/api/v1/emails",
    scopes: "email:send",
    description: "Send a single transactional email.",
    body: [
      { field: "from", type: "string", required: true, description: "Sender email address (must be from a verified domain)" },
      { field: "to", type: "string | string[]", required: true, description: "Recipient email address(es)" },
      { field: "subject", type: "string (1-998)", required: true, description: "Email subject line" },
      { field: "html", type: "string", required: false, description: "HTML body content" },
      { field: "text", type: "string", required: false, description: "Plain text body content" },
      { field: "replyTo", type: "string", required: false, description: "Reply-to address" },
      { field: "tags", type: "string[]", required: false, description: "Tags for categorization" },
      { field: "scheduledAt", type: "string (ISO 8601)", required: false, description: "Schedule delivery time" },
      { field: "idempotencyKey", type: "string", required: false, description: "Prevents duplicate sends within 24h" },
      { field: "attachmentIds", type: "string[] (uuid)", required: false, description: "IDs of previously uploaded attachments" },
    ],
  },
  {
    method: "POST",
    path: "/api/v1/emails/batch",
    scopes: "email:send",
    description: "Send emails in batch.",
    body: [
      { field: "messages", type: "object[]", required: true, description: "Array of email message objects (same schema as POST /emails)" },
    ],
  },
  {
    method: "POST",
    path: "/api/v1/emails/validate",
    scopes: "email:send",
    description: "Validate an email payload without sending.",
    body: [
      { field: "from", type: "string", required: true, description: "Sender email address" },
      { field: "to", type: "string | string[]", required: true, description: "Recipient email address(es)" },
      { field: "subject", type: "string", required: true, description: "Email subject line" },
      { field: "html", type: "string", required: false, description: "HTML body content" },
    ],
  },
  {
    method: "GET",
    path: "/api/v1/emails",
    scopes: "email:read",
    description: "List emails with optional filtering.",
    query: [
      { field: "status", type: "string", description: "Filter by status (queued/sending/delivered/bounced/failed)" },
      { field: "environment", type: "string", description: "Filter by environment (live/sandbox)" },
      { field: "after", type: "string", description: "Cursor for pagination" },
      { field: "limit", type: "number", description: "Maximum results returned" },
      { field: "page", type: "number", description: "Page number (default: 1)" },
      { field: "perPage", type: "number", description: "Items per page (default: 25)" },
    ],
  },
  {
    method: "GET",
    path: "/api/v1/emails/:id",
    scopes: "email:read",
    description: "Get a single email with full delivery details.",
  },
  {
    method: "POST",
    path: "/api/v1/emails/:id/cancel",
    scopes: "email:send",
    description: "Cancel a scheduled email.",
  },
  {
    method: "POST",
    path: "/api/v1/attachments",
    scopes: "email:send",
    description: "Upload a file attachment (multipart/form-data). Max size 25MB. Returns an attachment ID to use with send.",
  },
  {
    method: "GET",
    path: "/api/v1/domains",
    scopes: "domain:read",
    description: "List all verified and pending domains.",
  },
  {
    method: "POST",
    path: "/api/v1/domains",
    scopes: "domain:write",
    description: "Add a new sending domain.",
    body: [
      { field: "domain", type: "string", required: true, description: "Domain name (e.g. example.com)" },
    ],
  },
  {
    method: "POST",
    path: "/api/v1/domains/:id/verify",
    scopes: "domain:write",
    description: "Trigger DNS verification for a domain.",
  },
  {
    method: "DELETE",
    path: "/api/v1/domains/:id",
    scopes: "domain:write",
    description: "Permanently delete a sending domain.",
  },
  {
    method: "GET",
    path: "/api/v1/templates",
    scopes: "template:read",
    description: "List all email templates.",
    query: [
      { field: "page", type: "number", description: "Page number (default: 1)" },
      { field: "perPage", type: "number", description: "Items per page (default: 25)" },
    ],
  },
  {
    method: "POST",
    path: "/api/v1/templates",
    scopes: "template:write",
    description: "Create a new email template.",
    body: [
      { field: "name", type: "string", required: true, description: "Template name" },
      { field: "subject", type: "string", required: true, description: "Default subject line" },
      { field: "htmlBody", type: "string", required: false, description: "HTML body with {{variables}}" },
      { field: "textBody", type: "string", required: false, description: "Plain text body with {{variables}}" },
    ],
  },
  {
    method: "POST",
    path: "/api/v1/templates/:id/send",
    scopes: "email:send",
    description: "Send an email using a template.",
    body: [
      { field: "to", type: "string", required: true, description: "Recipient email address" },
      { field: "variables", type: "object", required: false, description: "Template variable values" },
    ],
  },
  {
    method: "GET",
    path: "/api/v1/webhooks",
    scopes: "webhook:read",
    description: "List all registered webhooks.",
  },
  {
    method: "POST",
    path: "/api/v1/webhooks",
    scopes: "webhook:write",
    description: "Register a new webhook endpoint.",
    body: [
      { field: "url", type: "string", required: true, description: "Webhook endpoint URL" },
      { field: "events", type: "string[] (min 1)", required: true, description: "Event types to subscribe to" },
      { field: "secret", type: "string", required: false, description: "Custom HMAC signing secret" },
    ],
  },
  {
    method: "DELETE",
    path: "/api/v1/webhooks/:id",
    scopes: "webhook:write",
    description: "Delete a webhook endpoint.",
  },
  {
    method: "POST",
    path: "/api/v1/webhooks/:id/rotate-secret",
    scopes: "webhook:write",
    description: "Rotate the HMAC signing secret for a webhook.",
  },
  {
    method: "GET",
    path: "/api/v1/webhooks/:id/deliveries",
    scopes: "webhook:read",
    description: "List delivery attempts for a webhook.",
    query: [
      { field: "page", type: "number", description: "Page number (default: 1)" },
      { field: "perPage", type: "number", description: "Items per page (default: 25)" },
    ],
  },
  {
    method: "POST",
    path: "/api/v1/webhooks/:id/replay/:deliveryId",
    scopes: "webhook:write",
    description: "Re-queue a webhook delivery for retry.",
  },
  {
    method: "GET",
    path: "/api/v1/suppressions",
    scopes: "email:read",
    description: "List suppressed email addresses.",
    query: [
      { field: "reason", type: "string", description: "Filter by reason (hard_bounce/complaint/manual/unsubscribed)" },
      { field: "page", type: "number", description: "Page number (default: 1)" },
      { field: "perPage", type: "number", description: "Items per page (default: 25)" },
    ],
  },
  {
    method: "POST",
    path: "/api/v1/suppressions",
    scopes: "email:send",
    description: "Add an email address to the suppression list.",
    body: [
      { field: "email", type: "string", required: true, description: "Email address to suppress" },
      { field: "reason", type: "string", required: false, description: "Suppression reason (defaults to manual)" },
    ],
  },
  {
    method: "DELETE",
    path: "/api/v1/suppressions/:id",
    scopes: "email:send",
    description: "Remove an email from the suppression list.",
  },
  {
    method: "GET",
    path: "/api/v1/analytics/overview",
    scopes: "analytics:read",
    description: "Get overall delivery analytics.",
  },
  {
    method: "GET",
    path: "/api/v1/dashboard/usage",
    scopes: "analytics:read",
    description: "Get email usage statistics for the current billing period.",
  },
  {
    method: "GET",
    path: "/api/v1/dashboard/providers",
    scopes: "analytics:read",
    description: "Get delivery breakdown by email provider.",
  },
  {
    method: "GET",
    path: "/api/v1/dashboard/activity",
    scopes: "analytics:read",
    description: "Get recent sending activity.",
  },
  {
    method: "GET",
    path: "/api/v1/dashboard/alerts",
    scopes: "analytics:read",
    description: "Get current account alerts.",
  },
  {
    method: "GET",
    path: "/api/v1/billing/plans",
    scopes: "none",
    description: "List available billing plans.",
  },
  {
    method: "GET",
    path: "/api/v1/billing/subscription",
    scopes: "analytics:read",
    description: "Get the current subscription and usage.",
  },
  {
    method: "POST",
    path: "/api/v1/billing/subscription/change",
    scopes: "api_key:write",
    description: "Change the organization's plan.",
    body: [
      { field: "planSlug", type: "string", required: true, description: "Slug of the plan to switch to" },
    ],
  },
  {
    method: "POST",
    path: "/api/v1/billing/overage",
    scopes: "api_key:write",
    description: "Enable or disable overage sending.",
    body: [
      { field: "enabled", type: "boolean", required: true, description: "Whether overage is enabled" },
    ],
  },
  {
    method: "POST",
    path: "/api/v1/billing/invoices/generate-overage",
    scopes: "api_key:write",
    description: "Generate an invoice for current overage usage.",
  },
  {
    method: "GET",
    path: "/api/v1/billing/invoices",
    scopes: "analytics:read",
    description: "List billing invoices.",
    query: [
      { field: "page", type: "number", description: "Page number (default: 1)" },
      { field: "perPage", type: "number", description: "Items per page (default: 25)" },
    ],
  },
  {
    method: "POST",
    path: "/api/v1/billing/invoices/:id/pay",
    scopes: "api_key:write",
    description: "Initialize Paystack payment for an invoice.",
  },
  {
    method: "POST",
    path: "/api/v1/billing/webhook/paystack",
    scopes: "none",
    description: "Paystack payment webhook endpoint (called by Paystack).",
  },
  {
    method: "GET",
    path: "/api/v1/audit-logs",
    scopes: "analytics:read",
    description: "List audit log entries for the organization.",
    query: [
      { field: "page", type: "number", description: "Page number (default: 1)" },
      { field: "perPage", type: "number", description: "Items per page (default: 25)" },
    ],
  },
  {
    method: "GET",
    path: "/track/open/:messageId.png",
    scopes: "none",
    description: "Open tracking pixel. Returns a transparent GIF and records an open event. Used in email HTML.",
  },
  {
    method: "GET",
    path: "/track/click/:messageId",
    scopes: "none",
    description: "Click tracking redirect. Records a click event then 302-redirects to the target URL.",
    query: [
      { field: "redirect", type: "string", description: "The original link URL to redirect to" },
    ],
  },
  {
    method: "GET",
    path: "/api/v1/health",
    scopes: "none",
    description: "Health check endpoint.",
  },
  {
    method: "GET",
    path: "/api/v1/ready",
    scopes: "none",
    description: "Readiness check endpoint.",
  },
  {
    method: "GET",
    path: "/metrics",
    scopes: "none",
    description: "Prometheus metrics endpoint.",
  },
  {
    method: "GET",
    path: "/docs",
    scopes: "none",
    description: "Swagger/OpenAPI interactive documentation.",
  },
];

export default function ApiReferencePage() {
  return (
    <div className="animate-fade-in">
      <h1 className="text-[32px] font-semibold tracking-tight text-text-primary mb-3">
        API Reference
      </h1>
      <p className="text-[16px] text-text-secondary mb-8 max-w-[640px]">
        All API endpoints are prefixed with <code className="text-text-primary">/api/v1</code>. 
        Base URL: <code className="text-text-primary">http://localhost:3001</code> (development) or <code className="text-text-primary">https://api.mailo.dev</code> (production)
      </p>

      <Section title="Base URL">
        <CodeBlock lang="text">
          http://localhost:3001/api/v1   # development
          https://api.mailo.dev/api/v1   # production
        </CodeBlock>
      </Section>

      <Section title="Headers">
        <p>All requests require the following headers:</p>
        <table className="w-full text-[14px]">
          <thead>
            <tr className="border-b border-[rgba(0,0,0,0.06)]">
              <th className="text-left py-2 pr-4 font-medium text-text-primary">Header</th>
              <th className="text-left py-2 pr-4 font-medium text-text-primary">Value</th>
              <th className="text-left py-2 font-medium text-text-primary">Description</th>
            </tr>
          </thead>
          <tbody>
            <tr className="border-b border-[rgba(0,0,0,0.04)]">
              <td className="py-2 pr-4 text-text-secondary font-mono text-[13px]">Authorization</td>
              <td className="py-2 pr-4 text-text-secondary font-mono text-[13px]">Bearer &lt;api_key&gt;</td>
              <td className="py-2 text-text-secondary">API key or JWT token</td>
            </tr>
            <tr className="border-b border-[rgba(0,0,0,0.04)]">
              <td className="py-2 pr-4 text-text-secondary font-mono text-[13px]">Content-Type</td>
              <td className="py-2 pr-4 text-text-secondary font-mono text-[13px]">application/json</td>
              <td className="py-2 text-text-secondary">Request body format</td>
            </tr>
            <tr>
              <td className="py-2 pr-4 text-text-secondary font-mono text-[13px]">Idempotency-Key</td>
              <td className="py-2 pr-4 text-text-secondary font-mono text-[13px]">&lt;uuid&gt;</td>
              <td className="py-2 text-text-secondary">Optional: prevent duplicate sends</td>
            </tr>
          </tbody>
        </table>
      </Section>

      <Section title="Endpoints">
        <div className="space-y-3">
          {endpoints.map((ep) => (
            <div key={`${ep.method}-${ep.path}`} className="glass-sm p-4">
              <div className="flex items-center gap-3 mb-2">
                <span className={clsx(
                  "text-[12px] font-semibold px-2 py-0.5 rounded-[4px] font-mono uppercase",
                  methodColor(ep.method),
                )}>
                  {ep.method}
                </span>
                <code className="text-[14px] text-text-primary font-mono">{ep.path}</code>
              </div>
              <p className="text-[14px] text-text-secondary mb-2">{ep.description}</p>
              {ep.scopes !== "none" && (
                <p className="text-[13px] text-text-tertiary mb-2">
                  Required scope: <code className="text-text-secondary">{ep.scopes}</code>
                </p>
              )}
              {ep.body && (
                <div className="mt-3">
                  <p className="text-[13px] font-medium text-text-primary mb-1.5">Request Body</p>
                  <table className="w-full text-[13px]">
                    <thead>
                      <tr className="border-b border-[rgba(0,0,0,0.06)]">
                        <th className="text-left py-1 pr-3 font-medium text-text-tertiary">Field</th>
                        <th className="text-left py-1 pr-3 font-medium text-text-tertiary">Type</th>
                        <th className="text-left py-1 pr-3 font-medium text-text-tertiary">Required</th>
                        <th className="text-left py-1 font-medium text-text-tertiary">Description</th>
                      </tr>
                    </thead>
                    <tbody>
                      {ep.body.map((param) => (
                        <tr key={param.field} className="border-b border-[rgba(0,0,0,0.03)]">
                          <td className="py-1 pr-3 font-mono text-text-primary">{param.field}</td>
                          <td className="py-1 pr-3 text-text-secondary">{param.type}</td>
                          <td className="py-1 pr-3">{param.required ? <span className="text-danger">required</span> : <span className="text-text-tertiary">optional</span>}</td>
                          <td className="py-1 text-text-secondary">{param.description}</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              )}
              {ep.query && (
                <div className="mt-3">
                  <p className="text-[13px] font-medium text-text-primary mb-1.5">Query Parameters</p>
                  <table className="w-full text-[13px]">
                    <thead>
                      <tr className="border-b border-[rgba(0,0,0,0.06)]">
                        <th className="text-left py-1 pr-3 font-medium text-text-tertiary">Field</th>
                        <th className="text-left py-1 pr-3 font-medium text-text-tertiary">Type</th>
                        <th className="text-left py-1 font-medium text-text-tertiary">Description</th>
                      </tr>
                    </thead>
                    <tbody>
                      {ep.query.map((param) => (
                        <tr key={param.field} className="border-b border-[rgba(0,0,0,0.03)]">
                          <td className="py-1 pr-3 font-mono text-text-primary">{param.field}</td>
                          <td className="py-1 pr-3 text-text-secondary">{param.type}</td>
                          <td className="py-1 text-text-secondary">{param.description}</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              )}
            </div>
          ))}
        </div>
      </Section>

      <Section title="Rate Limiting">
        <p>
          API requests are rate-limited per API key. Limits are as follows:
        </p>
        <ul className="list-disc pl-5 space-y-1">
          <li>Send endpoints: 100 requests per second</li>
          <li>Read endpoints: 300 requests per second</li>
          <li>Batch sends: 10 requests per second</li>
        </ul>
        <p className="mt-2">
          Rate limit information is returned in the response headers:
        </p>
        <CodeBlock lang="text">
          X-RateLimit-Limit: 100
          X-RateLimit-Remaining: 95
          X-RateLimit-Reset: 1620000000
        </CodeBlock>
      </Section>

      <Section title="Error Responses">
        <p>The API uses conventional HTTP response codes:</p>
        <table className="w-full text-[14px]">
          <thead>
            <tr className="border-b border-[rgba(0,0,0,0.06)]">
              <th className="text-left py-2 pr-4 font-medium text-text-primary">Code</th>
              <th className="text-left py-2 font-medium text-text-primary">Description</th>
            </tr>
          </thead>
          <tbody>
            <tr className="border-b border-[rgba(0,0,0,0.04)]">
              <td className="py-2 pr-4 font-mono text-[13px] text-success">200</td>
              <td className="py-2 text-text-secondary">Success</td>
            </tr>
            <tr className="border-b border-[rgba(0,0,0,0.04)]">
              <td className="py-2 pr-4 font-mono text-[13px] text-text-primary">400</td>
              <td className="py-2 text-text-secondary">Bad Request — invalid payload</td>
            </tr>
            <tr className="border-b border-[rgba(0,0,0,0.04)]">
              <td className="py-2 pr-4 font-mono text-[13px] text-text-primary">401</td>
              <td className="py-2 text-text-secondary">Unauthorized — missing or invalid API key</td>
            </tr>
            <tr className="border-b border-[rgba(0,0,0,0.04)]">
              <td className="py-2 pr-4 font-mono text-[13px] text-text-primary">403</td>
              <td className="py-2 text-text-secondary">Forbidden — insufficient permissions</td>
            </tr>
            <tr className="border-b border-[rgba(0,0,0,0.04)]">
              <td className="py-2 pr-4 font-mono text-[13px] text-text-primary">404</td>
              <td className="py-2 text-text-secondary">Not Found</td>
            </tr>
            <tr className="border-b border-[rgba(0,0,0,0.04)]">
              <td className="py-2 pr-4 font-mono text-[13px] text-text-primary">409</td>
              <td className="py-2 text-text-secondary">Conflict — duplicate idempotency key</td>
            </tr>
            <tr className="border-b border-[rgba(0,0,0,0.04)]">
              <td className="py-2 pr-4 font-mono text-[13px] text-text-primary">429</td>
              <td className="py-2 text-text-secondary">Too Many Requests — rate limit exceeded</td>
            </tr>
            <tr>
              <td className="py-2 pr-4 font-mono text-[13px] text-danger">500</td>
              <td className="py-2 text-text-secondary">Internal Server Error</td>
            </tr>
          </tbody>
        </table>
      </Section>

      <DocsPageNav current="/docs/api-reference" />
    </div>
  );
}

function Section({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <div className="mb-8">
      <h2 className="text-[22px] font-medium text-text-primary mb-3">{title}</h2>
      <div className="text-[15px] text-text-secondary leading-relaxed space-y-3">
        {children}
      </div>
    </div>
  );
}

function CodeBlock({ lang, children }: { lang: string; children: React.ReactNode }) {
  return (
    <pre className="bg-[#1d1d1f] text-[13px] text-[#f5f5f7] p-4 rounded-[10px] overflow-x-auto leading-relaxed font-mono">
      <code>{children}</code>
    </pre>
  );
}

function clsx(...classes: (string | boolean | undefined | null)[]): string {
  return classes.filter(Boolean).join(" ");
}

function methodColor(method: string): string {
  switch (method) {
    case "GET": return "text-success bg-[rgba(48,209,88,0.1)]";
    case "POST": return "text-text-primary bg-[rgba(51,51,51,0.1)]";
    case "DELETE": return "text-danger bg-[rgba(255,69,58,0.1)]";
    default: return "text-text-secondary bg-[rgba(110,110,115,0.1)]";
  }
}
