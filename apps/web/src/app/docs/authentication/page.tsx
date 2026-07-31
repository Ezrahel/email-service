import type { Metadata } from "next";
import { DocsPageNav } from "../DocsPageNav";

export const metadata: Metadata = {
  title: "Authentication — ResendByte Docs",
  description: "Learn how to authenticate with the ResendByte API using API keys and JWT tokens. Understand scopes, permissions, and security best practices.",
  openGraph: { title: "Authentication — ResendByte Docs" },
};

export default function AuthenticationPage() {
  return (
    <div className="animate-fade-in">
      <h1 className="text-[32px] font-semibold tracking-tight text-text-primary mb-3">
        Authentication
      </h1>
      <p className="text-[16px] text-text-secondary mb-8 max-w-[640px]">
        ResendByte supports two authentication methods: API keys for programmatic access 
        and JWT tokens for dashboard sessions.
      </p>

      <Section title="API Keys">
        <p>
          API keys are the primary way to authenticate with the ResendByte API. Each key 
          has a set of scopes that determine what actions it can perform.
        </p>

        <h3 className="text-[17px] font-medium text-text-primary mt-6 mb-2">Key Types</h3>
        <table className="w-full text-[14px]">
          <thead>
            <tr className="border-b border-[rgba(0,0,0,0.06)]">
              <th className="text-left py-2 pr-4 font-medium text-text-primary">Prefix</th>
              <th className="text-left py-2 pr-4 font-medium text-text-primary">Type</th>
              <th className="text-left py-2 font-medium text-text-primary">Behavior</th>
            </tr>
          </thead>
          <tbody>
            <tr className="border-b border-[rgba(0,0,0,0.04)]">
              <td className="py-2 pr-4 font-mono text-[13px]">live_</td>
              <td className="py-2 pr-4 text-text-secondary">Live</td>
              <td className="py-2 text-text-secondary">Sends real emails through configured providers</td>
            </tr>
            <tr>
              <td className="py-2 pr-4 font-mono text-[13px]">sandbox_</td>
              <td className="py-2 pr-4 text-text-secondary">Sandbox</td>
              <td className="py-2 text-text-secondary">Simulates sends — no emails are actually delivered</td>
            </tr>
          </tbody>
        </table>

        <h3 className="text-[17px] font-medium text-text-primary mt-6 mb-2">Available Scopes</h3>
        <table className="w-full text-[14px]">
          <thead>
            <tr className="border-b border-[rgba(0,0,0,0.06)]">
              <th className="text-left py-2 pr-4 font-medium text-text-primary">Scope</th>
              <th className="text-left py-2 font-medium text-text-primary">Permissions</th>
            </tr>
          </thead>
          <tbody>
            {scopes.map((s) => (
              <tr key={s.scope} className="border-b border-[rgba(0,0,0,0.04)]">
                <td className="py-2 pr-4 font-mono text-[13px] text-text-primary">{s.scope}</td>
                <td className="py-2 text-text-secondary">{s.description}</td>
              </tr>
            ))}
          </tbody>
        </table>

        <h3 className="text-[17px] font-medium text-text-primary mt-6 mb-2">Using API Keys</h3>
        <p>Include the API key in the Authorization header:</p>
        <CodeBlock lang="text">
          Authorization: Bearer live_sk_2a3b8c9d0e1f4a5b6c7d8e9f0a1b2c3d
        </CodeBlock>

        <h3 className="text-[17px] font-medium text-text-primary mt-6 mb-2">Security Best Practices</h3>
        <ul className="list-disc pl-5 space-y-1.5">
          <li>Use sandbox keys during development and testing</li>
          <li>Create separate API keys for each environment or service</li>
          <li>Assign only the minimum scopes needed</li>
          <li>Rotate keys regularly</li>
          <li>Use IP allowlisting for sensitive keys</li>
          <li>Never expose API keys in client-side code</li>
          <li>Revoke compromised keys immediately from the dashboard</li>
        </ul>
      </Section>

      <Section title="JWT Authentication">
        <p>
          JWT tokens are used for dashboard session authentication. Access tokens 
          expire after 15 minutes, and refresh tokens expire after 7 days.
        </p>

        <h3 className="text-[17px] font-medium text-text-primary mt-6 mb-2">Login</h3>
        <CodeBlock lang="bash">{`curl -X POST https://api.mailo.dev/api/v1/auth/login \\
  -H "Content-Type: application/json" \\
  -d '{
    "email": "user@example.com",
    "password": "your_password"
  }'`}</CodeBlock>

        <h3 className="text-[17px] font-medium text-text-primary mt-6 mb-2">Response</h3>
        <CodeBlock lang="json">
{`{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
  "expiresAt": "2026-07-30T14:00:00Z",
  "user": {
    "id": "usr_abc123",
    "email": "user@example.com",
    "firstName": "John",
    "lastName": "Doe",
    "organizationId": "org_xyz789"
  }
}`}
        </CodeBlock>

        <h3 className="text-[17px] font-medium text-text-primary mt-6 mb-2">Refresh Token</h3>
        <CodeBlock lang="bash">{`curl -X POST https://api.mailo.dev/api/v1/auth/refresh \\
  -H "Content-Type: application/json" \\
  -d '{
    "refreshToken": "eyJhbGciOiJIUzI1NiIs..."
  }'`}</CodeBlock>
      </Section>

      <Section title="IP Allowlisting">
        <p>
          For additional security, API keys can be restricted to specific IP addresses. 
          When IP allowlisting is enabled, requests from non-allowlisted IPs will be 
          rejected with a 403 Forbidden response.
        </p>
      </Section>

      <Section title="Idempotency">
        <p>
          To prevent duplicate email sends, include an <code>Idempotency-Key</code> header 
          with your requests. The key should be a unique UUID. If a request with the same 
          key is sent within 24 hours, the original response will be returned.
        </p>
        <CodeBlock lang="text">
          Idempotency-Key: 550e8400-e29b-41d4-a716-446655440000
        </CodeBlock>
      </Section>

      <DocsPageNav current="/docs/authentication" />
    </div>
  );
}

const scopes = [
  { scope: "email:send", description: "Send emails and cancel scheduled sends" },
  { scope: "email:read", description: "View email logs and delivery details" },
  { scope: "domain:read", description: "View sending domains" },
  { scope: "domain:write", description: "Add and verify sending domains" },
  { scope: "template:read", description: "View email templates" },
  { scope: "template:write", description: "Create and manage templates" },
  { scope: "webhook:read", description: "View webhook endpoints" },
  { scope: "webhook:write", description: "Create and manage webhooks" },
  { scope: "api_key:read", description: "View API keys" },
  { scope: "api_key:write", description: "Create and revoke API keys" },
  { scope: "analytics:read", description: "View analytics and dashboard data" },
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
