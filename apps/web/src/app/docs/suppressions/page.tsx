import type { Metadata } from "next";
import { DocsPageNav } from "../DocsPageNav";

export const metadata: Metadata = {
  title: "Suppressions — ResendByte Docs",
  description: "Manage email suppression lists to automatically prevent sending to invalid addresses, hard bounces, and spam complainers.",
  openGraph: { title: "Suppressions — ResendByte Docs" },
};

export default function SuppressionsPage() {
  return (
    <div className="animate-fade-in">
      <h1 className="text-[32px] font-semibold tracking-tight text-text-primary mb-3">
        Suppressions
      </h1>
      <p className="text-[16px] text-text-secondary mb-8 max-w-[640px]">
        Manage suppression lists to automatically prevent sending emails to 
        addresses that have bounced, complained, or unsubscribed.
      </p>

      <Section title="How Suppressions Work">
        <p>
          ResendByte automatically suppresses emails in the following scenarios:
        </p>
        <ul className="list-disc pl-5 space-y-1.5">
          <li><strong>Hard Bounce</strong> — The recipient's mail server rejected the email as undeliverable</li>
          <li><strong>Spam Complaint</strong> — The recipient marked an email as spam (via provider feedback loops)</li>
          <li><strong>Manual</strong> — You can manually add addresses to the suppression list</li>
          <li><strong>Unsubscribe</strong> — Addresses added through list-unsubscribe mechanisms</li>
        </ul>
        <p className="mt-3">
          When an email is sent to a suppressed address, it is automatically 
          skipped and marked as suppressed in the delivery logs.
        </p>
      </Section>

      <Section title="Managing Suppressions via API">
        <h3 className="text-[17px] font-medium text-text-primary mt-4 mb-2">List Suppressions</h3>
        <CodeBlock lang="bash">{`curl -X GET https://api.mailo.dev/api/v1/suppressions \\
  -H "Authorization: Bearer YOUR_API_KEY"`}</CodeBlock>

        <h3 className="text-[17px] font-medium text-text-primary mt-4 mb-2">Add a Suppression</h3>
        <CodeBlock lang="bash">{`curl -X POST https://api.mailo.dev/api/v1/suppressions \\
  -H "Authorization: Bearer YOUR_API_KEY" \\
  -H "Content-Type: application/json" \\
  -d '{
    "email": "bounced@example.com",
    "reason": "manual",
    "description": "User requested to be removed"
  }'`}</CodeBlock>

        <h3 className="text-[17px] font-medium text-text-primary mt-4 mb-2">Remove a Suppression</h3>
        <CodeBlock lang="bash">{`curl -X DELETE https://api.mailo.dev/api/v1/suppressions/:id \\
  -H "Authorization: Bearer YOUR_API_KEY"`}</CodeBlock>
      </Section>

      <Section title="Suppression Reasons">
        <table className="w-full text-[14px]">
          <thead>
            <tr className="border-b border-[rgba(0,0,0,0.06)]">
              <th className="text-left py-2 pr-4 font-medium text-text-primary">Reason</th>
              <th className="text-left py-2 font-medium text-text-primary">Description</th>
            </tr>
          </thead>
          <tbody>
            {reasons.map((r) => (
              <tr key={r.reason} className="border-b border-[rgba(0,0,0,0.04)]">
                <td className="py-2 pr-4 font-mono text-[13px]">{r.reason}</td>
                <td className="py-2 text-text-secondary">{r.description}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </Section>

      <Section title="Best Practices">
        <ul className="list-disc pl-5 space-y-1.5">
          <li>Regularly review your suppression list for patterns</li>
          <li>Investigate sudden increases in hard bounces — this may indicate list quality issues</li>
          <li>Respect suppression reasons — don't re-add addresses that have complained</li>
          <li>Use suppression lists alongside your own unsubscribe management</li>
          <li>Periodically clean your main sending lists by cross-referencing suppressions</li>
        </ul>
      </Section>

      <DocsPageNav current="/docs/suppressions" />
    </div>
  );
}

const reasons = [
  { reason: "hard_bounce", description: "Email was permanently rejected by the recipient's server" },
  { reason: "complaint", description: "Recipient reported the email as spam" },
  { reason: "manual", description: "Manually added through the API or dashboard" },
  { reason: "unsubscribed", description: "Recipient unsubscribed via list-unsubscribe" },
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
