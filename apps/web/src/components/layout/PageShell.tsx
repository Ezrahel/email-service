"use client";

import { clsx } from "clsx";

interface PageShellProps {
  title: string;
  subtitle?: string;
  actions?: React.ReactNode;
  children: React.ReactNode;
  className?: string;
}

export function PageShell({ title, subtitle, actions, children, className }: PageShellProps) {
  return (
    <div className={clsx("mx-auto w-full max-w-[1400px] px-6 py-6", className)}>
      <div className="flex items-start justify-between mb-6">
        <div>
          <h1 className="text-[24px] font-semibold tracking-tight text-text-primary">
            {title}
          </h1>
          {subtitle && (
            <p className="text-[15px] text-text-secondary mt-1">{subtitle}</p>
          )}
        </div>
        {actions && <div className="flex items-center gap-2 shrink-0 ml-4">{actions}</div>}
      </div>

      <div className="animate-fade-in">{children}</div>
    </div>
  );
}
