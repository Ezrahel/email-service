import type { Metadata } from "next";
import { DocsPageNav } from "../DocsPageNav";

export const metadata: Metadata = {
  title: "Billing — ResendByte Docs",
  description: "Learn about ResendByte's pricing plans, billing, usage tracking, and how to manage your subscription.",
  openGraph: { title: "Billing — ResendByte Docs" },
};

export default function BillingPage() {
  return (
    <div className="animate-fade-in">
      <h1 className="text-[32px] font-semibold tracking-tight text-text-primary mb-3">
        Billing
      </h1>
      <p className="text-[16px] text-text-secondary mb-8 max-w-[640px]">
        Understand ResendByte's pricing, manage your subscription, and track usage.
      </p>

      <Section title="Plans">
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
          {plans.map((plan) => (
            <div key={plan.name} className="glass-sm p-4">
              <h3 className="text-[17px] font-medium text-text-primary mb-1">{plan.name}</h3>
              <p className="text-[24px] font-semibold text-text-primary mb-2">
                {plan.price === 0 ? "Free" : `$${plan.price}/mo`}
              </p>
              <ul className="space-y-1">
                {plan.features.map((f) => (
                  <li key={f} className="text-[14px] text-text-secondary">{f}</li>
                ))}
              </ul>
            </div>
          ))}
        </div>
      </Section>

      <Section title="Usage Tracking">
        <p>
          Usage is tracked monthly and resets on your billing date. You can view 
          your current usage in the dashboard:
        </p>
        <CodeBlock lang="bash">{`curl -X GET https://api.mailo.dev/api/v1/dashboard/usage \\
  -H "Authorization: Bearer YOUR_API_KEY"`}</CodeBlock>
        <p className="mt-2">
          The response includes sent count, delivery breakdown, and percentage 
          of your monthly quota used.
        </p>
      </Section>

      <Section title="Overage">
        <p>
          When you exceed your plan's monthly email limit, overage charges apply. 
          You can enable or disable overage sending from the billing settings. 
          When overage is disabled, sending is paused once the limit is reached.
        </p>
      </Section>

      <Section title="Invoices">
        <p>
          Invoices are generated monthly and available via the API:
        </p>
        <CodeBlock lang="bash">{`curl -X GET https://api.mailo.dev/api/v1/billing/invoices \\
  -H "Authorization: Bearer YOUR_API_KEY"`}</CodeBlock>
      </Section>

      <Section title="Changing Plans">
        <p>
          Upgrade or downgrade your plan at any time. Changes take effect 
          immediately and prorated credits are applied:
        </p>
        <CodeBlock lang="bash">{`curl -X POST https://api.mailo.dev/api/v1/billing/subscription/change \\
  -H "Authorization: Bearer YOUR_API_KEY" \\
  -H "Content-Type: application/json" \\
  -d '{
    "planId": "pro"
  }'`}        </CodeBlock>
      </Section>

      <DocsPageNav current="/docs/billing" />
    </div>
  );
}

const plans = [
  {
    name: "Free",
    price: 0,
    features: ["100 emails/month", "1 domain", "7-day history", "Basic support"],
  },
  {
    name: "Pro",
    price: 49,
    features: ["50,000 emails/month", "10 domains", "90-day history", "Priority support", "API access"],
  },
  {
    name: "Enterprise",
    price: 299,
    features: ["500,000 emails/month", "Unlimited domains", "Unlimited history", "Dedicated support", "SLA", "Custom integration"],
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
