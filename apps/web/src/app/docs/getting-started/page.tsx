import type { Metadata } from "next";
import { DocsPageNav } from "../DocsPageNav";

export const metadata: Metadata = {
  title: "Getting Started — ResendByte Docs",
  description: "Learn how to get started with ResendByte. Send your first transactional email using our API or SMTP gateway.",
  openGraph: { title: "Getting Started — ResendByte Docs" },
};

export default function GettingStartedPage() {
  return (
    <div className="animate-fade-in">
      <h1 className="text-[32px] font-semibold tracking-tight text-text-primary mb-3">
        Getting Started
      </h1>
      <p className="text-[16px] text-text-secondary mb-8">
        Send your first transactional email in under 5 minutes.
      </p>

      <Section title="1. Get Your API Key">
        <p>
          Log in to your ResendByte dashboard and navigate to <strong>API Keys</strong>. 
          Create a new API key — you will receive a key with a <code>live_</code> or 
          <code>sandbox_</code> prefix. Sandbox keys simulate sends without actually 
          delivering emails, perfect for testing.
        </p>
        <CodeBlock lang="text">
          live_sk_2a3b8c9d0e1f4a5b6c7d8e9f0a1b2c3d
        </CodeBlock>
      </Section>

      <Section title="2. Verify a Domain">
        <p>
          Before sending emails, you need to verify a sending domain. Go to 
          <strong> Domains</strong> in the dashboard, add your domain, and configure 
          the DKIM, SPF, and DMARC DNS records provided.
        </p>
      </Section>

      <Section title="3. Send Your First Email">
        <p>Use the API to send a transactional email:</p>
        <CodeBlock lang="bash">{`curl -X POST https://api.mailo.dev/api/v1/emails \\
  -H "Authorization: Bearer live_sk_2a3b8c9d0e..." \\
  -H "Content-Type: application/json" \\
  -d '{
    "from": "newsletter@yourdomain.com",
    "to": ["user@example.com"],
    "subject": "Welcome to ResendByte",
    "html": "<h1>Welcome!</h1><p>Thanks for signing up.</p>"
  }'`}</CodeBlock>
      </Section>

      <Section title="4. Using the SMTP Gateway">
        <p>
          You can also send via SMTP on ports 587 (STARTTLS) or 2525 (TLS). 
          Use your API key ID as the username and the key secret as the password.
        </p>
        <CodeBlock lang="bash">{`curl -X POST https://api.mailo.dev/api/v1/emails \\
  -H "Authorization: Bearer YOUR_API_KEY" \\
  -H "Content-Type: application/json" \\
  -d '{
    "from": "sender@yourdomain.com",
    "to": ["recipient@example.com"],
    "subject": "Hello",
    "text": "Hello from Mailo!"
  }'`}</CodeBlock>
      </Section>

      <Section title="5. Monitor Delivery">
        <p>
          Track your email delivery in real-time from the dashboard. You can view 
          open rates, click rates, bounce statistics, and delivery timelines for 
          every message. Configure webhooks to receive delivery events programmatically.
        </p>
      </Section>

      <Section title="Next Steps">
        <ul className="list-disc pl-5 space-y-1.5">
          <li>Explore the <a href="/docs/api-reference" className="text-text-primary underline underline-offset-2 hover:no-underline">API Reference</a> for detailed endpoint documentation.</li>
          <li>Set up <a href="/docs/webhooks" className="text-text-primary underline underline-offset-2 hover:no-underline">Webhooks</a> to receive delivery events in real-time.</li>
          <li>Learn about <a href="/docs/domains" className="text-text-primary underline underline-offset-2 hover:no-underline">Domain Management</a> for optimal deliverability.</li>
          <li>Use <a href="/docs/templates" className="text-text-primary underline underline-offset-2 hover:no-underline">Templates</a> to manage your email designs.</li>
        </ul>
      </Section>

      <DocsPageNav current="/docs/getting-started" />
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
