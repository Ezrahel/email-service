import Link from "next/link";
import { ArrowLeft, ArrowRight } from "lucide-react";

interface DocsPageNavProps {
  current: string;
}

const docOrder: { href: string; label: string }[] = [
  { href: "/docs", label: "Overview" },
  { href: "/docs/getting-started", label: "Getting Started" },
  { href: "/docs/authentication", label: "Authentication" },
  { href: "/docs/emails", label: "Emails" },
  { href: "/docs/domains", label: "Domains" },
  { href: "/docs/templates", label: "Templates" },
  { href: "/docs/webhooks", label: "Webhooks" },
  { href: "/docs/suppressions", label: "Suppressions" },
  { href: "/docs/billing", label: "Billing" },
  { href: "/docs/architecture", label: "Architecture" },
  { href: "/docs/api-reference", label: "API Reference" },
];

export function DocsPageNav({ current }: DocsPageNavProps) {
  const idx = docOrder.findIndex((d) => d.href === current);
  const prev = idx > 0 ? docOrder[idx - 1] : null;
  const next = idx >= 0 && idx < docOrder.length - 1 ? docOrder[idx + 1] : null;

  return (
    <nav className="flex items-stretch gap-3 mt-12 pt-6 border-t border-[rgba(0,0,0,0.06)]">
      {prev ? (
        <Link
          href={prev.href}
          className="flex items-center gap-2 glass-sm px-4 py-3 text-[14px] text-text-secondary hover:bg-accent-glass hover:text-text-primary transition-all duration-200 group flex-1"
        >
          <ArrowLeft className="w-4 h-4 shrink-0 group-hover:-translate-x-0.5 transition-transform" />
          <span className="min-w-0">
            <span className="block text-[12px] text-text-tertiary">Previous</span>
            <span className="block truncate font-medium">{prev.label}</span>
          </span>
        </Link>
      ) : (
        <div className="flex-1" />
      )}

      {next ? (
        <Link
          href={next.href}
          className="flex items-center justify-end gap-2 glass-sm px-4 py-3 text-[14px] text-text-secondary hover:bg-accent-glass hover:text-text-primary transition-all duration-200 group flex-1 text-right"
        >
          <span className="min-w-0">
            <span className="block text-[12px] text-text-tertiary">Next</span>
            <span className="block truncate font-medium">{next.label}</span>
          </span>
          <ArrowRight className="w-4 h-4 shrink-0 group-hover:translate-x-0.5 transition-transform" />
        </Link>
      ) : (
        <div className="flex-1" />
      )}
    </nav>
  );
}
