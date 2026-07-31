"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { clsx } from "clsx";
import { useState } from "react";
import {
  BookOpen,
  Rocket,
  Code,
  Key,
  Send,
  Globe,
  FileText,
  Webhook,
  Ban,
  CreditCard,
  Server,
  ChevronDown,
  ChevronRight,
  Menu,
  X,
} from "lucide-react";

interface NavSection {
  title: string;
  items: { label: string; href: string; icon: React.ElementType }[];
}

const navSections: NavSection[] = [
  {
    title: "Getting Started",
    items: [
      { label: "Overview", href: "/docs", icon: BookOpen },
      { label: "Quickstart", href: "/docs/getting-started", icon: Rocket },
    ],
  },
  {
    title: "Platform",
    items: [
      { label: "Architecture", href: "/docs/architecture", icon: Server },
    ],
  },
  {
    title: "API Reference",
    items: [
      { label: "API Reference", href: "/docs/api-reference", icon: Code },
      { label: "Authentication", href: "/docs/authentication", icon: Key },
    ],
  },
  {
    title: "Features",
    items: [
      { label: "Emails", href: "/docs/emails", icon: Send },
      { label: "Domains", href: "/docs/domains", icon: Globe },
      { label: "Templates", href: "/docs/templates", icon: FileText },
      { label: "Webhooks", href: "/docs/webhooks", icon: Webhook },
      { label: "Suppressions", href: "/docs/suppressions", icon: Ban },
      { label: "Billing", href: "/docs/billing", icon: CreditCard },
    ],
  },
];

export function DocsSidebar() {
  const pathname = usePathname();
  const [mobileOpen, setMobileOpen] = useState(false);
  const [expandedSections, setExpandedSections] = useState<Set<string>>(
    () => new Set(navSections.map((s) => s.title)),
  );

  const toggleSection = (title: string) => {
    setExpandedSections((prev) => {
      const next = new Set(prev);
      if (next.has(title)) next.delete(title);
      else next.add(title);
      return next;
    });
  };

  const sidebar = (
    <div className="flex flex-col h-full">
      <div className="flex items-center h-14 px-4 border-b border-[rgba(0,0,0,0.06)] shrink-0">
        <Link href="/docs" className="font-semibold text-[17px] tracking-tight text-text-primary no-underline">
          ResendByte Docs
        </Link>
      </div>

      <nav className="flex-1 overflow-y-auto scrollbar-thin p-3">
        {navSections.map((section) => {
          const expanded = expandedSections.has(section.title);
          return (
            <div key={section.title} className="mb-2">
              <button
                onClick={() => toggleSection(section.title)}
                className="flex items-center gap-2 w-full px-2 py-1.5 text-[13px] font-semibold text-text-tertiary uppercase tracking-wider hover:text-text-secondary transition-colors"
              >
                {expanded ? <ChevronDown className="w-3.5 h-3.5" /> : <ChevronRight className="w-3.5 h-3.5" />}
                {section.title}
              </button>
              {expanded && (
                <div className="flex flex-col gap-0.5 mt-0.5">
                  {section.items.map((item) => {
                    const Icon = item.icon;
                    const active = pathname === item.href;
                    return (
                      <Link
                        key={item.href}
                        href={item.href}
                        className={clsx(
                          "flex items-center gap-3 px-3 py-2 rounded-[8px] text-[14px] font-medium transition-all duration-200",
                          active
                            ? "bg-accent-glass text-text-primary"
                            : "text-text-secondary hover:bg-accent-glass hover:text-text-primary",
                        )}
                      >
                        <Icon className="w-4 h-4 shrink-0" />
                        {item.label}
                      </Link>
                    );
                  })}
                </div>
              )}
            </div>
          );
        })}
      </nav>

      <div className="p-3 border-t border-[rgba(0,0,0,0.06)] shrink-0">
        <Link
          href="/dashboard"
          className="flex items-center gap-2 px-3 py-2 rounded-[8px] text-[14px] text-text-secondary hover:bg-accent-glass hover:text-text-primary transition-all duration-200"
        >
          <Server className="w-4 h-4" />
          Back to Dashboard
        </Link>
      </div>
    </div>
  );

  return (
    <>
      <button
        onClick={() => setMobileOpen(true)}
        className="fixed top-3 left-3 z-50 lg:hidden glass-sm p-2 rounded-[8px]"
      >
        <Menu className="w-5 h-5" />
      </button>

      {mobileOpen && (
        <div className="fixed inset-0 z-40 lg:hidden">
          <div className="absolute inset-0 bg-black/20" onClick={() => setMobileOpen(false)} />
          <div className="absolute left-0 top-0 bottom-0 w-64 bg-bg glass shadow-xl">
            {sidebar}
          </div>
        </div>
      )}

      <aside className="hidden lg:flex flex-col w-64 h-screen sticky top-0 glass border-r border-[rgba(0,0,0,0.06)] shrink-0">
        {sidebar}
      </aside>
    </>
  );
}
