"use client";

import { clsx } from "clsx";
import { Clock, Send, CheckCheck, AlertCircle, Activity } from "lucide-react";

const STATUS_CONFIG: Record<string, { variant: "success" | "warning" | "danger" | "info" | "neutral"; label: string }> = {
  queued: { variant: "warning", label: "Queued" },
  scheduled: { variant: "info", label: "Scheduled" },
  sending: { variant: "info", label: "Sending" },
  delivered: { variant: "success", label: "Delivered" },
  bounced: { variant: "danger", label: "Bounced" },
  opened: { variant: "info", label: "Opened" },
  clicked: { variant: "success", label: "Clicked" },
  complained: { variant: "danger", label: "Complained" },
  failed: { variant: "danger", label: "Failed" },
  cancelled: { variant: "neutral", label: "Cancelled" },
  retrying: { variant: "warning", label: "Retrying" },
};

const STATUS_ICONS: Record<string, React.ReactNode> = {
  queued: <Clock className="h-6 w-6" />,
  scheduled: <Clock className="h-6 w-6" />,
  sending: <Send className="h-6 w-6" />,
  delivered: <CheckCheck className="h-6 w-6" />,
  bounced: <AlertCircle className="h-6 w-6" />,
  opened: <EyeIcon />,
  clicked: <MousePointerIcon />,
  complained: <AlertCircle className="h-6 w-6" />,
  failed: <AlertCircle className="h-6 w-6" />,
  cancelled: <AlertCircle className="h-6 w-6" />,
  retrying: <Clock className="h-6 w-6" />,
};

function EyeIcon() {
  return (
    <svg className="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M2 12s3-7 10-7 10 7 10 7-3 7-10 7-10-7-10-7Z" />
      <circle cx="12" cy="12" r="3" />
    </svg>
  );
}

function MousePointerIcon() {
  return (
    <svg className="h-6 w-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M3 3l7.07 16.97 2.51-7.39 7.39-2.51L3 3z" />
      <path d="M13 13l6 6" />
    </svg>
  );
}

interface EmailStatusBadgeProps {
  status: string;
  large?: boolean;
}

export function EmailStatusBadge({ status, large }: EmailStatusBadgeProps) {
  const config = STATUS_CONFIG[status] || { variant: "neutral" as const, label: status };
  const icon = STATUS_ICONS[status] || <Activity className="h-6 w-6" />;

  return (
    <div className={clsx(
      "glass p-5 flex items-center gap-4",
      config.variant === "success" && "border-l-4 border-l-success",
      config.variant === "danger" && "border-l-4 border-l-danger",
      config.variant === "warning" && "border-l-4 border-l-warning",
      config.variant === "info" && "border-l-4 border-l-accent",
    )}>
      <div className={clsx(
        large ? "w-14 h-14" : "w-12 h-12",
        "rounded-xl flex items-center justify-center",
        config.variant === "success" && "bg-success/15 text-success",
        config.variant === "danger" && "bg-danger/15 text-danger",
        config.variant === "warning" && "bg-warning/15 text-warning",
        config.variant === "info" && "bg-accent-glass text-accent",
        config.variant === "neutral" && "bg-[rgba(0,0,0,0.04)] text-text-tertiary",
      )}>
        {icon}
      </div>
      <div>
        <p className={clsx(
          "font-semibold text-text-primary",
          large ? "text-[22px]" : "text-[20px]",
        )}>{config.label}</p>
      </div>
    </div>
  );
}
