import type { Metadata } from "next";
import { DocsPageNav } from "../DocsPageNav";

export const metadata: Metadata = {
  title: "Templates — ResendByte Docs",
  description: "Create and manage email templates with versioning, variables, and send emails directly from templates.",
  openGraph: { title: "Templates — ResendByte Docs" },
};

export default function TemplatesPage() {
  return (
    <div className="animate-fade-in">
      <h1 className="text-[32px] font-semibold tracking-tight text-text-primary mb-3">
        Templates
      </h1>
      <p className="text-[16px] text-text-secondary mb-8 max-w-[640px]">
        Create and manage reusable email templates with variable substitution 
        and versioning support.
      </p>

      <Section title="Creating a Template">
        <p>Create a template with HTML and plain text versions:</p>
        <CodeBlock lang="bash">{`curl -X POST https://api.mailo.dev/api/v1/templates \\
  -H "Authorization: Bearer YOUR_API_KEY" \\
  -H "Content-Type: application/json" \\
  -d '{
    "name": "welcome-email",
    "subject": "Welcome to {{app_name}}, {{name}}!",
    "html": "<h1>Welcome, {{name}}!</h1><p>Thanks for joining {{app_name}}.</p>",
    "text": "Welcome, {{name}}! Thanks for joining {{app_name}}."
  }'`}</CodeBlock>
      </Section>

      <Section title="Template Variables">
        <p>
          Templates support variable substitution using the <code>{`{{variable_name}}`}</code> 
          syntax. Variables are replaced with values provided when sending.
        </p>

        <h3 className="text-[17px] font-medium text-text-primary mt-5 mb-2">Example Template</h3>
        <CodeBlock lang="html">{`<h1>Hi {{firstName}}!</h1>
<p>Your verification code is: <strong>{{verificationCode}}</strong></p>
<p>This code expires in {{expiresIn}} minutes.</p>
<p>— The {{appName}} Team</p>`}</CodeBlock>

        <h3 className="text-[17px] font-medium text-text-primary mt-5 mb-2">Sending with Variables</h3>
        <CodeBlock lang="bash">{`curl -X POST https://api.mailo.dev/api/v1/templates/:id/send \\
  -H "Authorization: Bearer YOUR_API_KEY" \\
  -H "Content-Type: application/json" \\
  -d '{
    "to": ["user@example.com"],
    "variables": {
      "firstName": "John",
      "verificationCode": "123456",
      "expiresIn": "10",
      "appName": "MyApp"
    }
  }'`}</CodeBlock>
      </Section>

      <Section title="Template Versioning">
        <p>
          Templates support versioning. Each update creates a new version while 
          preserving previous versions. You can publish a specific version to 
          make it the active one used for sending.
        </p>
        <ul className="list-disc pl-5 space-y-1.5">
          <li>Previous versions are retained and can be rolled back to</li>
          <li>Only published versions can be used for sending</li>
          <li>Version history is available in the dashboard</li>
        </ul>
      </Section>

      <Section title="Use Cases">
        <div className="space-y-4">
          {useCases.map((uc) => (
            <div key={uc.title} className="glass-sm p-4">
              <h3 className="text-[15px] font-medium text-text-primary mb-1">{uc.title}</h3>
              <p className="text-[14px] text-text-secondary">{uc.description}</p>
            </div>
          ))}
        </div>
      </Section>

      <DocsPageNav current="/docs/templates" />
    </div>
  );
}

const useCases = [
  {
    title: "Password Reset",
    description: "Create a password reset template with variables for the reset link and expiration time. Send it from your auth service.",
  },
  {
    title: "Welcome Series",
    description: "Design onboarding emails with personalized content based on user attributes and preferences.",
  },
  {
    title: "Order Confirmations",
    description: "Build order receipt templates with dynamic product lists, pricing, and delivery estimates.",
  },
  {
    title: "Notifications",
    description: "Create reusable notification templates for alerts, reminders, and account updates.",
  },
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
