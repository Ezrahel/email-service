"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { clsx } from "clsx";
import {
  LayoutDashboard,
  Send,
  FileText,
  Globe,
  Webhook,
  Key,
  Ban,
  CreditCard,
  BookOpen,
  PanelLeftClose,
  PanelLeftOpen,
} from "lucide-react";

interface SidebarProps {
  collapsed?: boolean;
  onToggle?: () => void;
}

const navItems = [
  { label: "Dashboard", href: "/dashboard", icon: LayoutDashboard },
  { label: "Emails", href: "/emails", icon: Send },
  { label: "Templates", href: "/templates", icon: FileText },
  { label: "Domains", href: "/domains", icon: Globe },
  { label: "Webhooks", href: "/webhooks", icon: Webhook },
  { label: "API Keys", href: "/api-keys", icon: Key },
  { label: "Suppressions", href: "/suppressions", icon: Ban },
  { label: "Billing", href: "/billing", icon: CreditCard },
];

export function Sidebar({ collapsed, onToggle }: SidebarProps) {
  const pathname = usePathname();

  return (
    <aside
      className={clsx(
        "glass flex flex-col h-screen sticky top-0 transition-all duration-300",
        collapsed ? "w-16" : "w-56",
      )}
    >
      <div className="flex items-center h-14 px-4 border-b border-[rgba(0,0,0,0.06)] shrink-0">
        <span
          className={clsx(
            "font-semibold text-[17px] tracking-tight text-text-primary transition-opacity duration-200",
            collapsed && "opacity-0 invisible w-0 overflow-hidden",
          )}
        >
          ResendByte
        </span>
        {collapsed && (
          <span className="font-semibold text-[17px] tracking-tight text-text-primary mx-auto">
            M
          </span>
        )}
      </div>

      <nav className="flex-1 flex flex-col gap-1 p-2 overflow-y-auto scrollbar-thin">
        {navItems.map((item) => {
          const Icon = item.icon;
          const active = pathname === item.href || pathname.startsWith(item.href + "/");
          return (
            <Link
              key={item.href}
              href={item.href}
              className={clsx(
                "flex items-center gap-3 px-3 py-2.5 rounded-[10px] text-[15px] font-medium transition-all duration-200",
                active
                  ? "bg-accent-glass text-text-primary"
                  : "text-text-secondary hover:bg-accent-glass hover:text-text-primary",
                collapsed && "justify-center px-0",
              )}
            >
              <Icon className="w-5 h-5 shrink-0" />
              <span
                className={clsx(
                  "transition-opacity duration-200",
                  collapsed && "opacity-0 invisible w-0 overflow-hidden",
                )}
              >
                {item.label}
              </span>
            </Link>
          );
        })}
      </nav>

      <div className="p-2 border-t border-[rgba(0,0,0,0.06)] shrink-0 flex flex-col gap-1">
        <Link
          href="/docs"
          className={clsx(
            "flex items-center gap-3 px-3 py-2.5 rounded-[10px] text-[15px] font-medium transition-all duration-200",
            "text-text-secondary hover:bg-accent-glass hover:text-text-primary",
            collapsed && "justify-center px-0",
          )}
        >
          <BookOpen className="w-5 h-5 shrink-0" />
          <span
            className={clsx(
              "transition-opacity duration-200",
              collapsed && "opacity-0 invisible w-0 overflow-hidden",
            )}
          >
            Documentation
          </span>
        </Link>
        <button
          onClick={onToggle}
          className="flex items-center justify-center w-full px-3 py-2.5 rounded-[10px] text-text-secondary hover:bg-accent-glass hover:text-text-primary transition-all duration-200"
        >
          {collapsed ? (
            <PanelLeftOpen className="w-5 h-5" />
          ) : (
            <PanelLeftClose className="w-5 h-5" />
          )}
        </button>
      </div>
    </aside>
  );
}
