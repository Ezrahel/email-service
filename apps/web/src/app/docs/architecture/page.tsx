import type { Metadata } from "next";
import { DocsPageNav } from "../DocsPageNav";

export const metadata: Metadata = {
  title: "Architecture — ResendByte Docs",
  description: "Explore the ResendByte platform architecture — services, queues, data flow, and infrastructure design.",
  openGraph: { title: "Architecture — ResendByte Docs" },
};

export default function ArchitecturePage() {
  return (
    <div className="animate-fade-in">
      <h1 className="text-[32px] font-semibold tracking-tight text-text-primary mb-3">
        Platform Architecture
      </h1>
      <p className="text-[16px] text-text-secondary mb-8 max-w-[640px]">
        ResendByte is built as a modular, event-driven platform using TypeScript, 
        Fastify, BullMQ, and PostgreSQL.
      </p>

      <Section title="System Overview">
        <div className="glass-sm p-5 mb-4">
          <pre className="text-[13px] text-text-secondary font-mono leading-relaxed">{`
  ┌──────────────────────────────────────────┐
  │              Clients / Internet           │
  │  (REST API via curl/SDKs)  (SMTP port)   │
  └──────────┬───────────────────────┬────────┘
             │                      │
     ┌───────▼──────┐      ┌────────▼─────────┐
     │  Next.js Web  │      │   Fastify API    │
     │  (Dashboard)  │      │   Server (:3001) │
     │  (:3000)      │      │                  │
     └───────┬───────┘      └────────┬──────────┘
             │                       │
             │     ┌─────────────────▼──────────┐
             │     │    BullMQ Queue System     │
             │     │  email:critical | :high    │
             │     │  :default | :low           │
             │     │  delivery:retry | webhooks │
             │     │  analytics | maintenance   │
             │     └─────────────────┬──────────┘
             │                       │
  ┌──────────▼───────────────────────▼──────────┐
  │           Shared Infrastructure             │
  │  ┌──────────┐ ┌────────┐ ┌──────────┐      │
  │  │PostgreSQL│ │ Redis  │ │Minio/S3  │      │
  │  │ (primary)│ │(queues)│ │(attachments)     │
  │  └──────────┘ └────────┘ └──────────┘      │
  └─────────────────────────────────────────────┘`}</pre>
        </div>
      </Section>

      <Section title="Core Components">
        <div className="space-y-4">
          {components.map((comp) => (
            <div key={comp.name} className="glass-sm p-4">
              <h3 className="text-[15px] font-medium text-text-primary mb-1">{comp.name}</h3>
              <p className="text-[14px] text-text-secondary">{comp.description}</p>
            </div>
          ))}
        </div>
      </Section>

      <Section title="Email Delivery Flow">
        <p>The complete lifecycle of an email send:</p>
        <ol className="list-decimal pl-5 space-y-2 mt-3">
          <li><strong>Submit</strong> — Email is submitted via REST API (POST /api/v1/emails) or SMTP gateway</li>
          <li><strong>Authenticate</strong> — API server validates JWT or API key, checks IP allowlisting</li>
          <li><strong>Validate</strong> — Payload is validated with Zod schemas, idempotency key checked</li>
          <li><strong>Quota Check</strong> — Billing quota is verified against the organization's plan</li>
          <li><strong>Persist</strong> — Email is saved to the <code>email_messages</code> table</li>
          <li><strong>Enqueue</strong> — A BullMQ job is added to the appropriate priority queue</li>
          <li><strong>Process</strong> — Email processor worker picks up the job, tracks the sending domain, injects tracking pixel/links</li>
          <li><strong>Route</strong> — ProviderRegistry selects the best provider based on health, cost, and routing rules</li>
          <li><strong>Send</strong> — Email is sent via the selected provider (SES, SendGrid, Mailgun, etc.)</li>
          <li><strong>Record</strong> — Delivery result is recorded in <code>deliveries</code> and <code>email_metrics</code> tables</li>
          <li><strong>Notify</strong> — Webhook events are dispatched to registered webhook endpoints</li>
          <li><strong>Retry</strong> — On failure, delivery is retried with exponential backoff</li>
        </ol>
      </Section>

      <Section title="Workers">
        <table className="w-full text-[14px]">
          <thead>
            <tr className="border-b border-[rgba(0,0,0,0.06)]">
              <th className="text-left py-2 pr-4 font-medium text-text-primary">Worker</th>
              <th className="text-left py-2 pr-4 font-medium text-text-primary">Queues</th>
              <th className="text-left py-2 font-medium text-text-primary">Purpose</th>
            </tr>
          </thead>
          <tbody>
            {workers.map((w) => (
              <tr key={w.name} className="border-b border-[rgba(0,0,0,0.04)]">
                <td className="py-2 pr-4 font-mono text-[13px]">{w.name}</td>
                <td className="py-2 pr-4 text-text-secondary">{w.queues}</td>
                <td className="py-2 text-text-secondary">{w.purpose}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </Section>

      <Section title="Email Providers">
        <p>
          ResendByte supports multiple email delivery providers with automatic failover 
          and circuit breaker protection:
        </p>
        <ul className="list-disc pl-5 space-y-1.5 mt-2">
          <li><strong>Amazon SES</strong> — Reliable, low-cost cloud email service</li>
          <li><strong>SendGrid</strong> — High deliverability with advanced analytics</li>
          <li><strong>Mailgun</strong> — Developer-friendly email API</li>
          <li><strong>Postmark</strong> — Fast, reliable transactional email</li>
          <li><strong>SMTP</strong> — Direct SMTP sending for custom setups</li>
        </ul>
      </Section>

      <Section title="Technology Stack">
        <table className="w-full text-[14px]">
          <thead>
            <tr className="border-b border-[rgba(0,0,0,0.06)]">
              <th className="text-left py-2 pr-4 font-medium text-text-primary">Category</th>
              <th className="text-left py-2 font-medium text-text-primary">Technology</th>
            </tr>
          </thead>
          <tbody>
            {techStack.map((t) => (
              <tr key={t.category} className="border-b border-[rgba(0,0,0,0.04)]">
                <td className="py-2 pr-4 text-text-secondary">{t.category}</td>
                <td className="py-2 text-text-secondary">{t.tech}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </Section>

      <DocsPageNav current="/docs/architecture" />
    </div>
  );
}

const components = [
  { name: "Fastify API Server", description: "High-performance REST API server handling authentication, request validation, and routing. Serves as the main entry point for all API requests." },
  { name: "Next.js Dashboard", description: "Modern web application providing the ResendByte dashboard with real-time analytics, email logs, domain management, and billing." },
  { name: "BullMQ Queue System", description: "Redis-backed job queues with priority levels (critical, high, default, low) for reliable asynchronous email processing and delivery." },
  { name: "Provider Registry", description: "Pluggable provider adapter system with weighted routing, automatic failover, circuit breakers, and health checking across multiple email providers." },
  { name: "Worker Pool", description: "Dedicated workers for email processing, delivery retry, webhook dispatch, analytics rollup, and scheduled maintenance tasks." },
  { name: "PostgreSQL Database", description: "Primary data store with 32 tables covering organizations, users, emails, deliveries, templates, domains, webhooks, billing, and analytics." },
  { name: "SMTP Gateway", description: "SMTP server that receives emails via standard SMTP protocol and feeds them into the same processing pipeline as REST API submissions." },
  { name: "OpenTelemetry & Monitoring", description: "Distributed tracing via Jaeger, Prometheus metrics collection, and structured logging with Pino for full observability." },
];

const workers = [
  { name: "email-processor", queues: "email:critical, :high, :default, :low", purpose: "Processes email submissions, injects tracking, sends via provider registry with failover" },
  { name: "delivery-processor", queues: "delivery:retry", purpose: "Handles delivery callbacks, auto-suppresses bounces, manages retry with exponential backoff" },
  { name: "webhook-processor", queues: "webhook:delivery, :retry", purpose: "Delivers webhook events to registered endpoints with HMAC signing and retry" },
  { name: "analytics-processor", queues: "analytics", purpose: "Rolls up email metrics into pre-computed aggregate tables for dashboard queries" },
  { name: "scheduled", queues: "maintenance, email:default", purpose: "Handles periodic cleanup, retention policies, and domain DNS verification" },
];

const techStack = [
  { category: "Runtime", tech: "Node.js, TypeScript" },
  { category: "API Framework", tech: "Fastify" },
  { category: "Web App", tech: "Next.js 16, React 19, Tailwind CSS" },
  { category: "Database", tech: "PostgreSQL 16, Kysely (type-safe SQL)" },
  { category: "Queue", tech: "BullMQ, Redis 7" },
  { category: "Storage", tech: "Minio / S3-compatible" },
  { category: "Observability", tech: "OpenTelemetry, Jaeger, Prometheus, Grafana, Pino" },
  { category: "Validation", tech: "Zod" },
  { category: "Monorepo", tech: "pnpm, Turborepo" },
  { category: "Email Providers", tech: "SES, SendGrid, Mailgun, Postmark, SMTP" },
  { category: "Auth", tech: "JWT (jose), API keys, bcrypt, HMAC" },
];

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
