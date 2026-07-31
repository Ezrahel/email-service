import type { Metadata } from "next";
import Link from "next/link";
import { ArrowRight, Send, Globe, Webhook, Key, FileText, Ban, CreditCard, Server, Rocket } from "lucide-react";
import { DocsPageNav } from "./DocsPageNav";

export const metadata: Metadata = {
  title: "Documentation — ResendByte Email Platform",
  description: "ResendByte is a production-grade transactional email delivery platform. Learn how to integrate, send emails, and manage your email infrastructure.",
  openGraph: {
    title: "ResendByte Documentation",
    description: "Production-grade transactional email delivery platform documentation.",
  },
};

const sections = [
  {
    title: "Quickstart",
    description: "Send your first email in under 5 minutes.",
    href: "/docs/getting-started",
    icon: Rocket,
  },
  {
    title: "API Reference",
    description: "Complete API documentation for all endpoints.",
    href: "/docs/api-reference",
    icon: Send,
  },
  {
    title: "Authentication",
    description: "API keys, JWT tokens, and security scopes.",
    href: "/docs/authentication",
    icon: Key,
  },
  {
    title: "Domains",
    description: "Configure sending domains, DKIM, SPF, and DMARC.",
    href: "/docs/domains",
    icon: Globe,
  },
  {
    title: "Webhooks",
    description: "Receive real-time delivery events and notifications.",
    href: "/docs/webhooks",
    icon: Webhook,
  },
  {
    title: "Templates",
    description: "Create and manage email templates with versioning.",
    href: "/docs/templates",
    icon: FileText,
  },
  {
    title: "Suppressions",
    description: "Manage bounce and complaint suppression lists.",
    href: "/docs/suppressions",
    icon: Ban,
  },
  {
    title: "Billing",
    description: "Plans, pricing, and usage tracking.",
    href: "/docs/billing",
    icon: CreditCard,
  },
  {
    title: "Architecture",
    description: "Platform architecture and system design.",
    href: "/docs/architecture",
    icon: Server,
  },
];

export default function DocsPage() {
  return (
    <div className="animate-fade-in">
      <div className="mb-10">
        <h1 className="text-[32px] font-semibold tracking-tight text-text-primary mb-3">
          ResendByte Documentation
        </h1>
        <p className="text-[16px] text-text-secondary leading-relaxed max-w-[640px]">
          ResendByte is a production-grade transactional email delivery platform. 
          This documentation covers everything you need to integrate, send emails, 
          and manage your email infrastructure.
        </p>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
        {sections.map((section) => {
          const Icon = section.icon;
          return (
            <Link
              key={section.href}
              href={section.href}
              className="glass-sm p-5 hover:bg-accent-glass transition-all duration-200 group no-underline"
            >
              <div className="flex items-start gap-4">
                <div className="w-10 h-10 rounded-[10px] bg-accent-glass flex items-center justify-center shrink-0">
                  <Icon className="w-5 h-5 text-text-primary" />
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2 mb-1">
                    <h2 className="text-[17px] font-medium text-text-primary">
                      {section.title}
                    </h2>
                    <ArrowRight className="w-4 h-4 text-text-tertiary group-hover:text-text-primary transition-colors shrink-0" />
                  </div>
                  <p className="text-[14px] text-text-secondary leading-relaxed">
                    {section.description}
                  </p>
                </div>
              </div>
            </Link>
          );
        })}
      </div>

      <DocsPageNav current="/docs" />
    </div>
  );
}
