import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";

const API_KEY = process.env.EMAIL_SERVICE_API_KEY;
if (!API_KEY) {
  console.error("EMAIL_SERVICE_API_KEY environment variable is required");
  process.exit(1);
}

const BASE_URL = (process.env.EMAIL_SERVICE_BASE_URL || "http://localhost:3001").replace(/\/+$/, "");

async function api<T>(method: string, path: string, body?: unknown): Promise<T> {
  const url = `${BASE_URL}${path}`;
  const headers: Record<string, string> = {
    Authorization: `Bearer ${API_KEY}`,
  };
  if (body !== undefined) {
    headers["Content-Type"] = "application/json";
  }

  const res = await fetch(url, { method, headers, body: body !== undefined ? JSON.stringify(body) : undefined });
  if (res.status === 204) return undefined as T;
  const json: any = await res.json();
  if (!res.ok) {
    throw new Error(json?.error?.message || json?.message || `HTTP ${res.status}`);
  }
  return (json?.data ?? json) as T;
}

const server = new McpServer({
  name: "resendbyte-mcp",
  version: "0.1.0",
});

server.tool(
  "send_email",
  "Send an email through the Email Service",
  {
    from: z.string().email().describe("Sender email address"),
    to: z.union([z.string().email(), z.array(z.string().email())]).describe("Recipient email address or array of addresses"),
    subject: z.string().min(1).max(998).describe("Email subject line"),
    html: z.string().optional().describe("HTML body content"),
    text: z.string().optional().describe("Plain text body content"),
    replyTo: z.string().email().optional().describe("Reply-to email address"),
    tags: z.array(z.string()).optional().describe("Tags for categorization"),
    scheduledAt: z.string().optional().describe("ISO 8601 datetime for scheduled sending"),
  },
  async (args) => {
    const result = await api<{ emailId: string; environment: string }>("POST", "/api/v1/emails", args);
    return {
      content: [{ type: "text", text: `Email sent successfully. ID: ${result.emailId}, Environment: ${result.environment}` }],
    };
  },
);

server.tool(
  "list_emails",
  "List recent emails with pagination and optional status filter",
  {
    page: z.number().optional().describe("Page number (default: 1)"),
    perPage: z.number().optional().describe("Results per page (default: 20)"),
    status: z.string().optional().describe("Filter by status (queued, sent, delivered, failed, bounced, opened, clicked)"),
    limit: z.number().optional().describe("Maximum number of results"),
  },
  async (args) => {
    const searchParams = new URLSearchParams();
    if (args.page) searchParams.set("page", String(args.page));
    if (args.perPage) searchParams.set("perPage", String(args.perPage));
    if (args.status) searchParams.set("status", args.status);
    if (args.limit) searchParams.set("limit", String(args.limit));
    const qs = searchParams.toString();
    const result = await api<any>("GET", `/api/v1/emails${qs ? `?${qs}` : ""}`);
    const emails = result.data || result;
    const summary = (Array.isArray(emails) ? emails : []).slice(0, 10).map((e: any) =>
      `• ${e.id}: "${e.subject}" → ${e.to_address} [${e.status}]`
    ).join("\n");
    return {
      content: [{ type: "text", text: `Found ${result.meta?.total || emails.length} emails:\n${summary}` }],
    };
  },
);

server.tool(
  "get_email",
  "Get detailed information about a specific email by ID",
  {
    id: z.string().describe("Email message ID (UUID)"),
  },
  async (args) => {
    const email = await api<any>("GET", `/api/v1/emails/${args.id}`);
    const details = [
      `ID: ${email.id}`,
      `From: ${email.from_address}`,
      `To: ${email.to_address}`,
      `Subject: ${email.subject}`,
      `Status: ${email.status}`,
      `Environment: ${email.environment}`,
      `Created: ${email.created_at}`,
      email.sent_at ? `Sent: ${email.sent_at}` : null,
      email.delivered_at ? `Delivered: ${email.delivered_at}` : null,
      email.opened_at ? `Opened: ${email.opened_at}` : null,
      email.clicked_at ? `Clicked: ${email.clicked_at}` : null,
      email.failed_at ? `Failed: ${email.failed_at} — ${email.failure_reason || "No reason"}` : null,
    ].filter(Boolean).join("\n");
    return {
      content: [{ type: "text", text: details }],
    };
  },
);

server.tool(
  "create_domain",
  "Register a new sending domain for verification",
  {
    domain: z.string().describe("Domain name to register (e.g., example.com)"),
  },
  async (args) => {
    const domain = await api<any>("POST", "/api/v1/domains", { domain: args.domain });
    return {
      content: [{
        type: "text",
        text: `Domain "${args.domain}" registered. ID: ${domain.id}. Status: ${domain.status}. Verify DNS records to start sending.`,
      }],
    };
  },
);

server.tool(
  "verify_domain",
  "Start DNS verification for a registered domain",
  {
    id: z.string().describe("Domain ID (UUID)"),
  },
  async (args) => {
    await api("POST", `/api/v1/domains/${args.id}/verify`);
    return {
      content: [{ type: "text", text: `Domain ${args.id} verification started. Check domain status after DNS propagation.` }],
    };
  },
);

server.tool(
  "list_domains",
  "List all registered sending domains",
  {},
  async () => {
    const domains = await api<any[]>("GET", "/api/v1/domains");
    const summary = (Array.isArray(domains) ? domains : []).map((d: any) =>
      `• ${d.domain} [${d.status}] DKIM:${d.dkim_verified ? "✓" : "✗"} SPF:${d.spf_verified ? "✓" : "✗"}`
    ).join("\n");
    return {
      content: [{ type: "text", text: domains.length ? `Domains:\n${summary}` : "No domains registered." }],
    };
  },
);

server.tool(
  "list_templates",
  "List email templates",
  {
    page: z.number().optional().describe("Page number (default: 1)"),
    perPage: z.number().optional().describe("Results per page (default: 20)"),
  },
  async (args) => {
    const searchParams = new URLSearchParams();
    if (args.page) searchParams.set("page", String(args.page));
    if (args.perPage) searchParams.set("perPage", String(args.perPage));
    const qs = searchParams.toString();
    const result = await api<any>("GET", `/api/v1/templates${qs ? `?${qs}` : ""}`);
    const templates = result.data || result;
    const summary = (Array.isArray(templates) ? templates : []).map((t: any) =>
      `• ${t.name} (${t.slug}) — ${t.description || "No description"}`
    ).join("\n");
    return {
      content: [{ type: "text", text: `Templates:\n${summary}` }],
    };
  },
);

server.tool(
  "list_webhooks",
  "List all configured webhooks",
  {},
  async () => {
    const webhooks = await api<any[]>("GET", "/api/v1/webhooks");
    const summary = (Array.isArray(webhooks) ? webhooks : []).map((w: any) =>
      `• ${w.url} [${w.status}] Events: ${w.events.join(", ")}`
    ).join("\n");
    return {
      content: [{ type: "text", text: webhooks.length ? `Webhooks:\n${summary}` : "No webhooks configured." }],
    };
  },
);

server.tool(
  "send_template_email",
  "Send an email using a saved template",
  {
    templateId: z.string().describe("Template ID (UUID)"),
    to: z.string().email().describe("Recipient email address"),
    variables: z.record(z.string()).optional().describe("Template variable substitutions"),
  },
  async (args) => {
    const result = await api<{ emailId: string; environment: string }>("POST", `/api/v1/templates/${args.templateId}/send`, {
      to: args.to,
      variables: args.variables,
    });
    return {
      content: [{ type: "text", text: `Template email sent. ID: ${result.emailId}, Environment: ${result.environment}` }],
    };
  },
);

server.tool(
  "list_suppressions",
  "List suppressed email addresses",
  {
    page: z.number().optional().describe("Page number (default: 1)"),
    perPage: z.number().optional().describe("Results per page (default: 20)"),
    reason: z.string().optional().describe("Filter by reason (bounce, complaint, manual)"),
  },
  async (args) => {
    const searchParams = new URLSearchParams();
    if (args.page) searchParams.set("page", String(args.page));
    if (args.perPage) searchParams.set("perPage", String(args.perPage));
    if (args.reason) searchParams.set("reason", args.reason);
    const qs = searchParams.toString();
    const result = await api<any>("GET", `/api/v1/suppressions${qs ? `?${qs}` : ""}`);
    const suppressions = result.data || result;
    const summary = (Array.isArray(suppressions) ? suppressions : []).map((s: any) =>
      `• ${s.email} [${s.reason}]`
    ).join("\n");
    return {
      content: [{ type: "text", text: `Suppressions:\n${summary}` }],
    };
  },
);

server.tool(
  "add_suppression",
  "Add an email address to the suppression list",
  {
    email: z.string().email().describe("Email address to suppress"),
    reason: z.string().optional().describe("Reason (bounce, complaint, manual)"),
  },
  async (args) => {
    await api("POST", "/api/v1/suppressions", { email: args.email, reason: args.reason || "manual" });
    return {
      content: [{ type: "text", text: `Email ${args.email} suppressed.` }],
    };
  },
);

server.tool(
  "get_usage",
  "Get current billing usage and subscription info",
  {},
  async () => {
    const result = await api<any>("GET", "/api/v1/billing/subscription");
    const usage = result.usage || {};
    const sub = result.subscription;
    const lines = [
      `Plan: ${usage.planSlug || "free"}`,
      `Sent this month: ${usage.sentThisMonth?.toLocaleString() || 0}`,
      `Monthly limit: ${usage.limit?.toLocaleString() || "N/A"}`,
      `Overage: ${usage.overageEnabled ? "Enabled" : "Disabled"}`,
    ];
    if (sub) {
      lines.push(`Subscription: ${sub.status}`);
      lines.push(`Period: ${sub.periodStart} — ${sub.periodEnd}`);
    }
    return {
      content: [{ type: "text", text: lines.join("\n") }],
    };
  },
);

async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error("Email Service MCP Server running on stdio");
}

main().catch((err) => {
  console.error("Fatal error:", err);
  process.exit(1);
});
