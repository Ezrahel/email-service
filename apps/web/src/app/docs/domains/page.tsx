import type { Metadata } from "next";
import { DocsPageNav } from "../DocsPageNav";

export const metadata: Metadata = {
  title: "Domains — ResendByte Docs",
  description: "Learn how to configure sending domains, DKIM, SPF, and DMARC DNS records for optimal email deliverability.",
  openGraph: { title: "Domains — ResendByte Docs" },
};

export default function DomainsPage() {
  return (
    <div className="animate-fade-in">
      <h1 className="text-[32px] font-semibold tracking-tight text-text-primary mb-3">
        Domains
      </h1>
      <p className="text-[16px] text-text-secondary mb-8 max-w-[640px]">
        Configure and verify sending domains to establish sender reputation and 
        ensure optimal email deliverability.
      </p>

      <Section title="Adding a Domain">
        <p>Add a sending domain through the API:</p>
        <CodeBlock lang="bash">{`curl -X POST https://api.mailo.dev/api/v1/domains \\
  -H "Authorization: Bearer YOUR_API_KEY" \\
  -H "Content-Type: application/json" \\
  -d '{
    "domain": "yourdomain.com"
  }'`}</CodeBlock>

        <p className="mt-3">
          The response will include the DNS records you need to configure:
        </p>
        <CodeBlock lang="json">{`{
  "id": "dom_abc123",
  "domain": "yourdomain.com",
  "status": "pending",
  "dnsRecords": [
    {
      "type": "TXT",
      "name": "resendbyte._domainkey.yourdomain.com",
      "value": "v=DKIM1; h=sha256; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQ..."
    },
    {
      "type": "TXT",
      "name": "yourdomain.com",
      "value": "v=spf1 include:mailo.dev ~all"
    },
    {
      "type": "TXT",
      "name": "_dmarc.yourdomain.com",
      "value": "v=DMARC1; p=quarantine; rua=mailto:dmarc@yourdomain.com"
    }
  ]
}`}</CodeBlock>
      </Section>

      <Section title="DNS Records">
        <p>
          Three DNS records are required for proper domain verification and 
          deliverability:
        </p>

        <h3 className="text-[17px] font-medium text-text-primary mt-5 mb-2">DKIM (DomainKeys Identified Mail)</h3>
        <p>
          DKIM adds a digital signature to your emails, allowing receiving servers 
          to verify that the email was not tampered with during transit.
        </p>
        <table className="w-full text-[14px]">
          <thead>
            <tr className="border-b border-[rgba(0,0,0,0.06)]">
              <th className="text-left py-2 pr-4 font-medium text-text-primary">Field</th>
              <th className="text-left py-2 font-medium text-text-primary">Value</th>
            </tr>
          </thead>
          <tbody>
            <tr className="border-b border-[rgba(0,0,0,0.04)]">
              <td className="py-2 pr-4 text-text-secondary">Type</td>
              <td className="py-2 font-mono text-[13px]">TXT</td>
            </tr>
            <tr className="border-b border-[rgba(0,0,0,0.04)]">
              <td className="py-2 pr-4 text-text-secondary">Name</td>
              <td className="py-2 font-mono text-[13px]">resendbyte._domainkey.yourdomain.com</td>
            </tr>
            <tr>
              <td className="py-2 pr-4 text-text-secondary">Value</td>
              <td className="py-2 font-mono text-[13px]">v=DKIM1; h=sha256; k=rsa; p=...</td>
            </tr>
          </tbody>
        </table>

        <h3 className="text-[17px] font-medium text-text-primary mt-5 mb-2">SPF (Sender Policy Framework)</h3>
        <p>
          SPF specifies which mail servers are authorized to send email on behalf 
          of your domain.
        </p>
        <table className="w-full text-[14px]">
          <thead>
            <tr className="border-b border-[rgba(0,0,0,0.06)]">
              <th className="text-left py-2 pr-4 font-medium text-text-primary">Field</th>
              <th className="text-left py-2 font-medium text-text-primary">Value</th>
            </tr>
          </thead>
          <tbody>
            <tr className="border-b border-[rgba(0,0,0,0.04)]">
              <td className="py-2 pr-4 text-text-secondary">Type</td>
              <td className="py-2 font-mono text-[13px]">TXT</td>
            </tr>
            <tr className="border-b border-[rgba(0,0,0,0.04)]">
              <td className="py-2 pr-4 text-text-secondary">Name</td>
              <td className="py-2 font-mono text-[13px]">yourdomain.com</td>
            </tr>
            <tr>
              <td className="py-2 pr-4 text-text-secondary">Value</td>
              <td className="py-2 font-mono text-[13px]">v=spf1 include:mailo.dev ~all</td>
            </tr>
          </tbody>
        </table>

        <h3 className="text-[17px] font-medium text-text-primary mt-5 mb-2">DMARC (Domain-based Message Authentication, Reporting & Conformance)</h3>
        <p>
          DMARC tells receiving mail servers how to handle emails that fail DKIM 
          or SPF checks.
        </p>
        <table className="w-full text-[14px]">
          <thead>
            <tr className="border-b border-[rgba(0,0,0,0.06)]">
              <th className="text-left py-2 pr-4 font-medium text-text-primary">Field</th>
              <th className="text-left py-2 font-medium text-text-primary">Value</th>
            </tr>
          </thead>
          <tbody>
            <tr className="border-b border-[rgba(0,0,0,0.04)]">
              <td className="py-2 pr-4 text-text-secondary">Type</td>
              <td className="py-2 font-mono text-[13px]">TXT</td>
            </tr>
            <tr className="border-b border-[rgba(0,0,0,0.04)]">
              <td className="py-2 pr-4 text-text-secondary">Name</td>
              <td className="py-2 font-mono text-[13px]">_dmarc.yourdomain.com</td>
            </tr>
            <tr>
              <td className="py-2 pr-4 text-text-secondary">Value</td>
              <td className="py-2 font-mono text-[13px]">v=DMARC1; p=quarantine; rua=mailto:dmarc@yourdomain.com</td>
            </tr>
          </tbody>
        </table>
      </Section>

      <Section title="Verifying a Domain">
        <p>
          After configuring the DNS records, trigger verification:
        </p>
        <CodeBlock lang="bash">{`curl -X POST https://api.mailo.dev/api/v1/domains/:id/verify \\
  -H "Authorization: Bearer YOUR_API_KEY"`}</CodeBlock>
        <p className="mt-2">
          ResendByte checks for the presence and correctness of the DNS records. 
          DNS propagation can take up to 48 hours, though it usually completes 
          within a few minutes.
        </p>
      </Section>

      <Section title="Deleting a Domain">
        <p>
          To permanently delete a domain and remove it from your account:
        </p>
        <CodeBlock lang="bash">{`curl -X DELETE https://api.mailo.dev/api/v1/domains/:id \\
  -H "Authorization: Bearer YOUR_API_KEY"`}</CodeBlock>
        <p className="mt-2">
          Deleting a domain is permanent and cannot be undone. Emails sent from the 
          domain will be affected, and the domain will need to be re-added and 
          re-verified before you can send from it again.
        </p>
      </Section>

      <Section title="Domain Statuses">
        <table className="w-full text-[14px]">
          <thead>
            <tr className="border-b border-[rgba(0,0,0,0.06)]">
              <th className="text-left py-2 pr-4 font-medium text-text-primary">Status</th>
              <th className="text-left py-2 font-medium text-text-primary">Description</th>
            </tr>
          </thead>
          <tbody>
            <tr className="border-b border-[rgba(0,0,0,0.04)]">
              <td className="py-2 pr-4 font-mono text-[13px]">pending</td>
              <td className="py-2 text-text-secondary">Domain added, waiting for DNS configuration</td>
            </tr>
            <tr className="border-b border-[rgba(0,0,0,0.04)]">
              <td className="py-2 pr-4 font-mono text-[13px]">verifying</td>
              <td className="py-2 text-text-secondary">DNS records are being checked</td>
            </tr>
            <tr className="border-b border-[rgba(0,0,0,0.04)]">
              <td className="py-2 pr-4 font-mono text-[13px]">verified</td>
              <td className="py-2 text-text-secondary">All DNS records are correctly configured</td>
            </tr>
            <tr>
              <td className="py-2 pr-4 font-mono text-[13px]">failed</td>
              <td className="py-2 text-text-secondary">DNS verification failed — check your records</td>
            </tr>
          </tbody>
        </table>
      </Section>

      <Section title="Deliverability Best Practices">
        <ul className="list-disc pl-5 space-y-1.5">
          <li>Warm up new domains by gradually increasing sending volume</li>
          <li>Monitor bounce rates and investigate sudden increases</li>
          <li>Set up DMARC reporting to monitor authentication failures</li>
          <li>Use a separate subdomain for transactional vs marketing emails</li>
          <li>Maintain consistent sending patterns and volume</li>
          <li>Regularly clean your recipient lists to remove invalid addresses</li>
          <li>Monitor your sender reputation through feedback loops</li>
        </ul>
      </Section>

      <DocsPageNav current="/docs/domains" />
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
