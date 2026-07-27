"use client";

import { clsx } from "clsx";
import { Clock, Send, CheckCheck } from "lucide-react";

const TIMELINE_STEPS = [
  { key: "queued", icon: <Clock className="h-5 w-5" />, label: "Queued" },
  { key: "sending", icon: <Send className="h-5 w-5" />, label: "Sending" },
  { key: "delivered", icon: <CheckCheck className="h-5 w-5" />, label: "Delivered" },
];

interface DeliveryTimelineProps {
  deliveries: Array<{ id: string; status: string; delivered_at?: string; created_at: string }>;
  status: string;
}

export function DeliveryTimeline({ status }: DeliveryTimelineProps) {
  return (
    <div className="glass p-5">
      <h3 className="text-[15px] font-semibold text-text-primary mb-4">Delivery Timeline</h3>
      <div className="flex items-center">
        {TIMELINE_STEPS.map((step, i) => {
          const currentIndex = TIMELINE_STEPS.findIndex((s) => s.key === status);
          const stepActiveIndex = currentIndex >= 0 ? currentIndex : -1;
          const isActive = i <= stepActiveIndex;
          const isLast = i === TIMELINE_STEPS.length - 1;
          return (
            <div key={step.key} className={clsx("flex items-center", isLast ? "" : "flex-1")}>
              <div className="flex items-center gap-3">
                <div className={clsx(
                  "w-10 h-10 rounded-full flex items-center justify-center transition-colors",
                  isActive ? "bg-accent text-white" : "bg-[rgba(0,0,0,0.04)] text-text-tertiary",
                )}>
                  {step.icon}
                </div>
                <span className={clsx(
                  "text-[14px] font-medium whitespace-nowrap",
                  isActive ? "text-text-primary" : "text-text-tertiary",
                )}>{step.label}</span>
              </div>
              {!isLast && (
                <div className={clsx(
                  "flex-1 h-px mx-4",
                  isActive ? "bg-accent" : "bg-[rgba(0,0,0,0.08)]",
                )} />
              )}
            </div>
          );
        })}
      </div>
    </div>
  );
}
