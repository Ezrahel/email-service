import type { Metadata } from "next";
import { DocsPageNav } from "../DocsPageNav";

export const metadata: Metadata = {
  title: "Emails — ResendByte Docs",
  description: "Learn how to send transactional emails, use templates, batch sending, schedule delivery, and track email performance.",
  openGraph: { title: "Emails — ResendByte Docs" },
};

export default function EmailsPage() {
  return (
    <div className="animate-fade-in">
      <h1 className="text-[32px] font-semibold tracking-tight text-text-primary mb-3">
        Emails
      </h1>
      <p className="text-[16px] text-text-secondary mb-8 max-w-[640px]">
        Send transactional emails through the ResendByte API with full control over 
        delivery, tracking, and scheduling.
      </p>

      <Section title="Send an Email">
        <p>Send a single transactional email:</p>
        <CodeBlock lang="bash">{`curl -X POST https://api.mailo.dev/api/v1/emails \\
  -H "Authorization: Bearer YOUR_API_KEY" \\
  -H "Content-Type: application/json" \\
  -d '{
    "from": "sender@yourdomain.com",
    "to": ["recipient@example.com"],
    "subject": "Welcome to our service",
    "html": "<h1>Welcome!</h1><p>Thanks for joining.</p>",
    "text": "Welcome! Thanks for joining.",
    "tags": ["welcome", "onboarding"]
  }'`}</CodeBlock>
      </Section>

      <Section title="Required Fields">
        <table className="w-full text-[14px]">
          <thead>
            <tr className="border-b border-[rgba(0,0,0,0.06)]">
              <th className="text-left py-2 pr-4 font-medium text-text-primary">Field</th>
              <th className="text-left py-2 pr-4 font-medium text-text-primary">Type</th>
              <th className="text-left py-2 font-medium text-text-primary">Description</th>
            </tr>
          </thead>
          <tbody>
            <tr className="border-b border-[rgba(0,0,0,0.04)]">
              <td className="py-2 pr-4 font-mono text-[13px]">from</td>
              <td className="py-2 pr-4 text-text-secondary">string</td>
              <td className="py-2 text-text-secondary">Sender email address. Must be from a verified domain.</td>
            </tr>
            <tr className="border-b border-[rgba(0,0,0,0.04)]">
              <td className="py-2 pr-4 font-mono text-[13px]">to</td>
              <td className="py-2 pr-4 text-text-secondary">string | string[]</td>
              <td className="py-2 text-text-secondary">Single recipient or array of recipients.</td>
            </tr>
            <tr className="border-b border-[rgba(0,0,0,0.04)]">
              <td className="py-2 pr-4 font-mono text-[13px]">subject</td>
              <td className="py-2 pr-4 text-text-secondary">string</td>
              <td className="py-2 text-text-secondary">Email subject line.</td>
            </tr>
            <tr>
              <td className="py-2 pr-4 font-mono text-[13px]">html or text</td>
              <td className="py-2 pr-4 text-text-secondary">string</td>
              <td className="py-2 text-text-secondary">At least one body format is required.</td>
            </tr>
          </tbody>
        </table>
      </Section>

      <Section title="Optional Fields">
        <table className="w-full text-[14px]">
          <thead>
            <tr className="border-b border-[rgba(0,0,0,0.06)]">
              <th className="text-left py-2 pr-4 font-medium text-text-primary">Field</th>
              <th className="text-left py-2 pr-4 font-medium text-text-primary">Type</th>
              <th className="text-left py-2 font-medium text-text-primary">Description</th>
            </tr>
          </thead>
          <tbody>
            {optionalFields.map((f) => (
              <tr key={f.field} className="border-b border-[rgba(0,0,0,0.04)]">
                <td className="py-2 pr-4 font-mono text-[13px]">{f.field}</td>
                <td className="py-2 pr-4 text-text-secondary">{f.type}</td>
                <td className="py-2 text-text-secondary">{f.description}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </Section>

      <Section title="Batch Sending">
        <p>Send up to 1000 emails in a single request:</p>
        <CodeBlock lang="bash">{`curl -X POST https://api.mailo.dev/api/v1/emails/batch \\
  -H "Authorization: Bearer YOUR_API_KEY" \\
  -H "Content-Type: application/json" \\
  -d '{
    "messages": [
      {
        "from": "sender@yourdomain.com",
        "to": ["user1@example.com"],
        "subject": "Hello User 1",
        "html": "<p>Hi user 1</p>"
      },
      {
        "from": "sender@yourdomain.com",
        "to": ["user2@example.com"],
        "subject": "Hello User 2",
        "html": "<p>Hi user 2</p>"
      }
    ]
  }'`}</CodeBlock>
      </Section>

      <Section title="Scheduled Delivery">
        <p>
          Schedule emails for future delivery by providing an ISO 8601 timestamp 
          in the <code>scheduledAt</code> field:
        </p>
        <CodeBlock lang="json">{`{
  "from": "sender@yourdomain.com",
  "to": ["user@example.com"],
  "subject": "Scheduled Email",
  "html": "<p>This will be sent later.</p>",
  "scheduledAt": "2026-08-01T09:00:00Z"
}`}</CodeBlock>
        <p className="mt-2">
          Scheduled emails can be cancelled using the <code>/api/v1/emails/:id/cancel</code> endpoint.
        </p>
      </Section>

      <Section title="Email Validation">
        <p>
          Validate an email payload before sending using the validate endpoint. 
          This checks for required fields, proper formatting, and template variable 
          completeness without actually sending:
        </p>
        <CodeBlock lang="bash">{`curl -X POST https://api.mailo.dev/api/v1/emails/validate \\
  -H "Authorization: Bearer YOUR_API_KEY" \\
  -H "Content-Type: application/json" \\
  -d '{
    "from": "sender@yourdomain.com",
    "to": ["recipient@example.com"],
    "subject": "Test",
    "html": "<p>Test</p>"
  }'`}</CodeBlock>
      </Section>

      <Section title="Tracking">
        <p>
          ResendByte automatically tracks email engagement:
        </p>
        <ul className="list-disc pl-5 space-y-1.5">
          <li><strong>Opens</strong> — An invisible tracking pixel is injected into HTML emails</li>
          <li><strong>Clicks</strong> — Links in HTML emails are wrapped with tracking redirects</li>
          <li><strong>Bounces</strong> — Delivery failures are categorized (hard bounce, soft bounce)</li>
          <li><strong>Complaints</strong> — Spam reports are captured from provider feedback loops</li>
        </ul>
        <p className="mt-3">
          Tracking data is available via the <a href="/docs/api-reference" className="text-text-primary underline underline-offset-2 hover:no-underline">API</a> and in the dashboard analytics.
        </p>
      </Section>

      <Section title="Attachments">
        <p>
          Upload attachments first via the attachments endpoint (multipart/form-data, 
          max 25MB per file), then reference them by <code>attachmentIds</code> in your 
          email send request:
        </p>
        <CodeBlock lang="bash">{`curl -X POST http://localhost:3001/api/v1/attachments \\
  -H "Authorization: Bearer YOUR_API_KEY" \\
  -F "file=@/path/to/document.pdf"`}</CodeBlock>
        <p className="mt-2">
          The response includes an attachment <code>id</code> which you pass in the 
          <code>attachmentIds</code> array when sending an email.
        </p>
      </Section>

      <Section title="Delivery Statuses">
        <table className="w-full text-[14px]">
          <thead>
            <tr className="border-b border-[rgba(0,0,0,0.06)]">
              <th className="text-left py-2 pr-4 font-medium text-text-primary">Status</th>
              <th className="text-left py-2 font-medium text-text-primary">Description</th>
            </tr>
          </thead>
          <tbody>
            {statuses.map((s) => (
              <tr key={s.status} className="border-b border-[rgba(0,0,0,0.04)]">
                <td className="py-2 pr-4 font-mono text-[13px]">{s.status}</td>
                <td className="py-2 text-text-secondary">{s.description}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </Section>

      <DocsPageNav current="/docs/emails" />
    </div>
  );
}

const optionalFields = [
  { field: "replyTo", type: "string", description: "Reply-to address" },
  { field: "tags", type: "string[]", description: "Tags for categorization and filtering" },
  { field: "scheduledAt", type: "string", description: "ISO 8601 timestamp for scheduled delivery" },
  { field: "idempotencyKey", type: "string", description: "UUID to prevent duplicate sends within 24h" },
  { field: "attachmentIds", type: "string[]", description: "Array of attachment IDs from prior upload" },
];

const statuses = [
  { status: "queued", description: "Email has been queued for processing" },
  { status: "sending", description: "Email is being sent via the provider" },
  { status: "delivered", description: "Email was accepted by the recipient's mail server" },
  { status: "opened", description: "Recipient opened the email (tracking pixel loaded)" },
  { status: "clicked", description: "Recipient clicked a tracked link in the email" },
  { status: "bounced", description: "Email was rejected by the recipient's mail server" },
  { status: "complained", description: "Recipient marked the email as spam" },
  { status: "failed", description: "Delivery failed after all retry attempts" },
  { status: "cancelled", description: "Scheduled email was cancelled before sending" },
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
