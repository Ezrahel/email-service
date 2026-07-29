"use client";

import { clsx } from "clsx";
import { Clock, Send, CheckCheck, Eye, MousePointerClick, AlertTriangle, ChevronDown, ChevronUp } from "lucide-react";
import { useState } from "react";

interface TimelineStep {
  key: string;
  icon: React.ReactNode;
  label: string;
  timestamp?: string;
  detail?: string;
}

interface DeliveryTimelineProps {
  deliveries: Array<{ id: string; status: string; provider?: string; delivered_at?: string; sent_at?: string; created_at: string; failure_reason?: string; response_code?: string }>;
  status: string;
  metrics?: { is_opened?: boolean; is_clicked?: boolean; is_complained?: boolean; open_count?: number; click_count?: number; opened_at?: string; clicked_at?: string; complained_at?: string; bounced_at?: string; is_bounced?: boolean };
  scheduledAt?: string;
}

function formatDate(dateStr?: string): string {
  if (!dateStr) return "";
  return new Date(dateStr).toLocaleString();
}

export function DeliveryTimeline({ status, metrics, deliveries, scheduledAt }: DeliveryTimelineProps) {
  const [expandedDelivery, setExpandedDelivery] = useState<string | null>(null);
  const delivery = deliveries?.[0];

  const steps: TimelineStep[] = [
    { key: "scheduled", icon: <Clock className="h-5 w-5" />, label: "Scheduled", timestamp: scheduledAt },
    { key: "queued", icon: <Clock className="h-5 w-5" />, label: "Queued", timestamp: delivery?.created_at },
    { key: "sending", icon: <Send className="h-5 w-5" />, label: "Sending", timestamp: delivery?.sent_at },
    { key: "delivered", icon: <CheckCheck className="h-5 w-5" />, label: "Delivered", timestamp: delivery?.delivered_at },
    { key: "opened", icon: <Eye className="h-5 w-5" />, label: "Opened", timestamp: metrics?.opened_at, detail: metrics?.open_count ? `${metrics.open_count} opens` : undefined },
    { key: "clicked", icon: <MousePointerClick className="h-5 w-5" />, label: "Clicked", timestamp: metrics?.clicked_at, detail: metrics?.click_count ? `${metrics.click_count} clicks` : undefined },
  ];

  const statusOrder = ["scheduled", "queued", "sending", "delivered", "opened", "clicked"];
  const currentIdx = statusOrder.indexOf(status);

  const activeSteps = steps.filter((s) => {
    if (s.key === "scheduled") return status === "scheduled" || !!scheduledAt;
    if (s.key === "opened" || s.key === "clicked") return !!s.timestamp || !!metrics?.is_opened || !!metrics?.is_clicked;
    if (s.key === "sending") return !!s.timestamp || currentIdx > statusOrder.indexOf("queued");
    return true;
  });

  return (
    <div className="glass p-5">
      <h3 className="text-[15px] font-semibold text-text-primary mb-4">Delivery Timeline</h3>
      <div className="space-y-1">
        {activeSteps.map((step, i) => {
          const stepIdx = statusOrder.indexOf(step.key);
          const isActive = stepIdx >= 0 && currentIdx >= 0 && stepIdx <= currentIdx;
          const isFailed = status === "bounced" || status === "failed" || status === "complained";
          return (
            <div key={step.key} className="flex gap-4">
              <div className="flex flex-col items-center">
                <div className={clsx(
                  "w-9 h-9 rounded-full flex items-center justify-center shrink-0",
                  isActive && !isFailed ? "bg-accent text-white" : "bg-[rgba(0,0,0,0.04)] text-text-tertiary",
                  isFailed && step.key === "delivered" ? "bg-danger/15 text-danger" : "",
                )}>
                  {isFailed && step.key === "delivered" ? <AlertTriangle className="h-4 w-4" /> : step.icon}
                </div>
                {i < activeSteps.length - 1 && <div className={clsx("w-px flex-1 min-h-[12px]", isActive ? "bg-accent/40" : "bg-[rgba(0,0,0,0.06)]")} />}
              </div>
              <div className="pb-5 flex-1">
                <div className="flex items-center gap-2">
                  <span className={clsx("text-[14px] font-medium", isActive ? "text-text-primary" : "text-text-tertiary")}>{step.label}</span>
                  {step.timestamp && <span className="text-[12px] text-text-tertiary">{formatDate(step.timestamp)}</span>}
                </div>
                {step.detail && <p className="text-[12px] text-text-tertiary mt-0.5">{step.detail}</p>}
                {step.key === "delivered" && delivery?.provider && (
                  <p className="text-[12px] text-text-tertiary mt-0.5">Provider: {delivery.provider}</p>
                )}
              </div>
            </div>
          );
        })}
        {metrics?.is_bounced && (
          <div className="flex gap-4">
            <div className="flex flex-col items-center">
              <div className="w-9 h-9 rounded-full flex items-center justify-center bg-danger/15 text-danger shrink-0">
                <AlertTriangle className="h-4 w-4" />
              </div>
            </div>
            <div className="pb-5">
              <div className="flex items-center gap-2">
                <span className="text-[14px] font-medium text-danger">Bounced</span>
                {metrics.bounced_at && <span className="text-[12px] text-text-tertiary">{formatDate(metrics.bounced_at)}</span>}
              </div>
            </div>
          </div>
        )}
        {metrics?.is_complained && (
          <div className="flex gap-4">
            <div className="flex flex-col items-center">
              <div className="w-9 h-9 rounded-full flex items-center justify-center bg-danger/15 text-danger shrink-0">
                <AlertTriangle className="h-4 w-4" />
              </div>
            </div>
            <div className="pb-5">
              <div className="flex items-center gap-2">
                <span className="text-[14px] font-medium text-danger">Complained</span>
                {metrics.complained_at && <span className="text-[12px] text-text-tertiary">{formatDate(metrics.complained_at)}</span>}
              </div>
            </div>
          </div>
        )}
      </div>

      {deliveries && deliveries.length > 0 && (
        <>
          <h4 className="text-[14px] font-medium text-text-primary mt-4 mb-2">SMTP Trace</h4>
          <div className="space-y-2">
            {deliveries.map((d) => (
              <div key={d.id}>
                <button
                  onClick={() => setExpandedDelivery(expandedDelivery === d.id ? null : d.id)}
                  className="w-full flex items-center justify-between glass-sm px-4 py-2.5 rounded-lg text-left hover:bg-accent-glass transition-colors"
                >
                  <div className="flex items-center gap-3">
                    <span className="text-[13px] font-medium text-text-primary">{d.provider || "unknown"}</span>
                    <span className={clsx("text-[12px] px-2 py-0.5 rounded-full", d.status === "delivered" ? "bg-success/10 text-success" : d.status === "failed" ? "bg-danger/10 text-danger" : "bg-warning/10 text-warning")}>
                      {d.status}
                    </span>
                    <span className="text-[12px] text-text-tertiary">{formatDate(d.created_at)}</span>
                  </div>
                  {expandedDelivery === d.id ? <ChevronUp className="h-4 w-4 text-text-tertiary" /> : <ChevronDown className="h-4 w-4 text-text-tertiary" />}
                </button>
                {expandedDelivery === d.id && (
                  <div className="glass-sm mt-1 p-4 rounded-lg font-mono text-[12px] space-y-2">
                    <div><span className="text-text-tertiary">ID:</span> <span className="text-text-primary">{d.id}</span></div>
                    <div><span className="text-text-tertiary">Status:</span> <span className="text-text-primary">{d.status}</span></div>
                    {d.sent_at && <div><span className="text-text-tertiary">Sent at:</span> <span className="text-text-primary">{formatDate(d.sent_at)}</span></div>}
                    {d.delivered_at && <div><span className="text-text-tertiary">Delivered at:</span> <span className="text-text-primary">{formatDate(d.delivered_at)}</span></div>}
                    {d.response_code && <div><span className="text-text-tertiary">Response:</span> <span className="text-text-primary">{d.response_code}</span></div>}
                    {d.failure_reason && <div><span className="text-text-tertiary">Error:</span> <span className="text-danger">{d.failure_reason}</span></div>}
                  </div>
                )}
              </div>
            ))}
          </div>
        </>
      )}
    </div>
  );
}
