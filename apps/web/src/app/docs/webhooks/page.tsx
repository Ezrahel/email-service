import type { Metadata } from "next";
import { DocsPageNav } from "../DocsPageNav";

export const metadata: Metadata = {
  title: "Webhooks — ResendByte Docs",
  description: "Receive real-time delivery events with webhooks. Learn about event types, payload format, signing, and best practices.",
  openGraph: { title: "Webhooks — ResendByte Docs" },
};

export default function WebhooksPage() {
  return (
    <div className="animate-fade-in">
      <h1 className="text-[32px] font-semibold tracking-tight text-text-primary mb-3">
        Webhooks
      </h1>
      <p className="text-[16px] text-text-secondary mb-8 max-w-[640px]">
        Receive real-time notifications about email delivery events. Webhooks 
        allow your application to react to delivery status changes programmatically.
      </p>

      <Section title="Creating a Webhook">
        <p>Register a webhook endpoint to receive events:</p>
        <CodeBlock lang="bash">{`curl -X POST https://api.mailo.dev/api/v1/webhooks \\
  -H "Authorization: Bearer YOUR_API_KEY" \\
  -H "Content-Type: application/json" \\
  -d '{
    "url": "https://your-app.com/webhooks/resendbyte",
    "events": [
      "delivery.delivered",
      "delivery.bounced",
      "delivery.opened",
      "delivery.clicked",
      "delivery.complained"
    ],
    "description": "Production webhook"
  }'`}</CodeBlock>
      </Section>

      <Section title="Event Types">
        <table className="w-full text-[14px]">
          <thead>
            <tr className="border-b border-[rgba(0,0,0,0.06)]">
              <th className="text-left py-2 pr-4 font-medium text-text-primary">Event</th>
              <th className="text-left py-2 font-medium text-text-primary">Description</th>
            </tr>
          </thead>
          <tbody>
            {events.map((e) => (
              <tr key={e.event} className="border-b border-[rgba(0,0,0,0.04)]">
                <td className="py-2 pr-4 font-mono text-[13px]">{e.event}</td>
                <td className="py-2 text-text-secondary">{e.description}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </Section>

      <Section title="Payload Format">
        <p>All webhook payloads follow this structure:</p>
        <CodeBlock lang="json">{`{
  "event": "delivery.delivered",
  "id": "evt_abc123",
  "createdAt": "2026-07-30T12:00:00Z",
  "data": {
    "emailMessageId": "msg_xyz789",
    "organizationId": "org_123",
    "from": "sender@yourdomain.com",
    "to": "recipient@example.com",
    "subject": "Welcome!",
    "status": "delivered",
    "provider": "ses",
    "providerResponse": "OK",
    "metadata": {
      "tags": ["welcome", "onboarding"]
    },
    "timestamp": "2026-07-30T12:00:00Z"
  }
}`}</CodeBlock>
      </Section>

      <Section title="Webhook Signing">
        <p>
          Each webhook payload is signed with an HMAC-SHA256 signature to verify 
          it came from ResendByte. The signature is sent in the <code>X-ResendByte-Signature</code> 
          header.
        </p>

        <h3 className="text-[17px] font-medium text-text-primary mt-5 mb-2">Verifying Signatures</h3>
        <p>Use your webhook secret to verify the HMAC signature:</p>
        <CodeBlock lang="javascript">{`const crypto = require("crypto");

function verifyWebhookSignature(
  payload: string,
  signature: string,
  secret: string
): boolean {
  const expected = crypto
    .createHmac("sha256", secret)
    .update(payload)
    .digest("hex");
  return crypto.timingSafeEqual(
    Buffer.from(signature),
    Buffer.from(expected)
  );
}`}</CodeBlock>
      </Section>

      <Section title="Retry Policy">
        <p>
          ResendByte will attempt to deliver webhook events up to 10 times with 
          exponential backoff:
        </p>
        <table className="w-full text-[14px]">
          <thead>
            <tr className="border-b border-[rgba(0,0,0,0.06)]">
              <th className="text-left py-2 pr-4 font-medium text-text-primary">Attempt</th>
              <th className="text-left py-2 font-medium text-text-primary">Wait Time</th>
            </tr>
          </thead>
          <tbody>
            <tr className="border-b border-[rgba(0,0,0,0.04)]">
              <td className="py-2 pr-4 font-mono text-[13px]">1</td>
              <td className="py-2 text-text-secondary">10 seconds</td>
            </tr>
            <tr className="border-b border-[rgba(0,0,0,0.04)]">
              <td className="py-2 pr-4 font-mono text-[13px]">2</td>
              <td className="py-2 text-text-secondary">30 seconds</td>
            </tr>
            <tr className="border-b border-[rgba(0,0,0,0.04)]">
              <td className="py-2 pr-4 font-mono text-[13px]">3</td>
              <td className="py-2 text-text-secondary">1 minute</td>
            </tr>
            <tr className="border-b border-[rgba(0,0,0,0.04)]">
              <td className="py-2 pr-4 font-mono text-[13px]">4</td>
              <td className="py-2 text-text-secondary">2 minutes</td>
            </tr>
            <tr className="border-b border-[rgba(0,0,0,0.04)]">
              <td className="py-2 pr-4 font-mono text-[13px]">5</td>
              <td className="py-2 text-text-secondary">5 minutes</td>
            </tr>
            <tr className="border-b border-[rgba(0,0,0,0.04)]">
              <td className="py-2 pr-4 font-mono text-[13px]">6-10</td>
              <td className="py-2 text-text-secondary">1 hour</td>
            </tr>
          </tbody>
        </table>
        <p className="mt-2">
          Your endpoint should return a 2xx status code within 10 seconds to 
          acknowledge receipt. After 10 failed attempts, the event is dropped.
        </p>
      </Section>

      <Section title="Best Practices">
        <ul className="list-disc pl-5 space-y-1.5">
          <li>Return a 2xx status code as quickly as possible to avoid timeouts</li>
          <li>Process webhook events asynchronously (queue them for background processing)</li>
          <li>Verify HMAC signatures before processing the payload</li>
          <li>Use idempotent processing — the same event may be delivered more than once</li>
          <li>Respond with a 4xx status to permanently reject an event you don't want</li>
          <li>Rotate webhook secrets periodically via the dashboard or API</li>
        </ul>
      </Section>

      <Section title="Managing Webhooks">
        <h3 className="text-[17px] font-medium text-text-primary mt-4 mb-2">Rotate Secret</h3>
        <CodeBlock lang="bash">{`curl -X POST https://api.mailo.dev/api/v1/webhooks/:id/rotate-secret \\
  -H "Authorization: Bearer YOUR_API_KEY"`}</CodeBlock>

        <h3 className="text-[17px] font-medium text-text-primary mt-4 mb-2">View Delivery Logs</h3>
        <CodeBlock lang="bash">{`curl -X GET https://api.mailo.dev/api/v1/webhooks/:id/deliveries \\
  -H "Authorization: Bearer YOUR_API_KEY"`}</CodeBlock>

        <h3 className="text-[17px] font-medium text-text-primary mt-4 mb-2">Replay a Delivery</h3>
        <CodeBlock lang="bash">{`curl -X POST https://api.mailo.dev/api/v1/webhooks/:id/replay/:deliveryId \\
  -H "Authorization: Bearer YOUR_API_KEY"`}</CodeBlock>

        <h3 className="text-[17px] font-medium text-text-primary mt-4 mb-2">Delete a Webhook</h3>
        <CodeBlock lang="bash">{`curl -X DELETE https://api.mailo.dev/api/v1/webhooks/:id \\
  -H "Authorization: Bearer YOUR_API_KEY"`}</CodeBlock>
      </Section>

      <DocsPageNav current="/docs/webhooks" />
    </div>
  );
}

const events = [
  { event: "delivery.delivered", description: "Email was accepted by the recipient's mail server" },
  { event: "delivery.bounced", description: "Email was rejected (hard or soft bounce)" },
  { event: "delivery.opened", description: "Recipient opened the email" },
  { event: "delivery.clicked", description: "Recipient clicked a tracked link" },
  { event: "delivery.complained", description: "Recipient marked email as spam" },
  { event: "email.failed", description: "Email delivery permanently failed" },
  { event: "email.sent", description: "Email was sent via the provider" },
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
