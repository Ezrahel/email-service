import { clsx } from "clsx";
import { CheckCircle } from "lucide-react";
import { relativeTime } from "@/lib/format";

interface AlertData {
  id: string;
  type: string;
  message: string;
  severity: string;
  created_at: string;
}

interface AlertsPanelProps {
  data: AlertData[];
}

export function AlertsPanel({ data }: AlertsPanelProps) {
  return (
    <div className="glass p-5 animate-fade-in">
      <h3 className="text-[15px] font-semibold text-text-primary mb-4">Alerts</h3>
      {data.length === 0 ? (
        <div className="flex items-center gap-2 py-3">
          <CheckCircle className="h-4 w-4 text-success" />
          <span className="text-[14px] text-text-secondary">No alerts &mdash; all clear</span>
        </div>
      ) : (
        <div className="flex flex-col gap-2">
          {data.map((alert) => (
            <div
              key={alert.id}
              className="flex items-center gap-3 py-2 px-3 rounded-[8px] bg-accent-glass text-[14px]"
            >
              <span
                className={clsx(
                  "w-1.5 h-1.5 rounded-full shrink-0",
                  alert.severity === "critical" || alert.severity === "error"
                    ? "bg-danger"
                    : alert.severity === "warning"
                      ? "bg-warning"
                      : "bg-accent",
                )}
              />
              <span className="text-text-primary">{alert.message}</span>
              <span className="ml-auto text-text-tertiary text-[13px] whitespace-nowrap">
                {relativeTime(alert.created_at)}
              </span>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
