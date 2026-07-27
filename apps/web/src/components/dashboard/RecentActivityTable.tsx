import { Badge } from "@/components/ui/Badge";
import { relativeTime } from "@/lib/format";

const STATUS_MAP: Record<string, { variant: "success" | "warning" | "danger" | "info" | "neutral"; label: string }> = {
  delivered: { variant: "success", label: "Delivered" },
  bounced: { variant: "danger", label: "Bounced" },
  opened: { variant: "info", label: "Opened" },
  clicked: { variant: "info", label: "Clicked" },
  complained: { variant: "warning", label: "Complained" },
  sending: { variant: "warning", label: "Sending" },
  queued: { variant: "neutral", label: "Queued" },
  failed: { variant: "danger", label: "Failed" },
};

interface RecentEmail {
  id: string;
  created_at: string;
  status: string;
  recipient: string;
  subject: string;
}

interface RecentActivityTableProps {
  data: RecentEmail[];
}

export function RecentActivityTable({ data }: RecentActivityTableProps) {
  if (!data.length) return null;

  return (
    <div className="glass p-5 animate-fade-in">
      <h3 className="text-[15px] font-semibold text-text-primary mb-4">Recent Activity</h3>
      <div className="overflow-x-auto scrollbar-thin max-h-[360px] overflow-y-auto">
        <table className="w-full border-collapse">
          <thead>
            <tr className="text-left text-[13px] font-medium text-text-secondary tracking-wide">
              <th className="pb-2 pr-4">Time</th>
              <th className="pb-2 pr-4">Status</th>
              <th className="pb-2 pr-4">Recipient</th>
              <th className="pb-2">Subject</th>
            </tr>
          </thead>
          <tbody>
            {data.map((email) => {
              const statusInfo = STATUS_MAP[email.status] || { variant: "neutral" as const, label: email.status };
              return (
                <tr key={email.id} className="border-t border-[rgba(0,0,0,0.04)]">
                  <td className="py-2.5 pr-4 text-[14px] text-text-secondary whitespace-nowrap">
                    {relativeTime(email.created_at)}
                  </td>
                  <td className="py-2.5 pr-4">
                    <Badge variant={statusInfo.variant} dot>
                      {statusInfo.label}
                    </Badge>
                  </td>
                  <td className="py-2.5 pr-4 text-[14px] text-text-primary max-w-[180px] truncate">
                    {email.recipient}
                  </td>
                  <td className="py-2.5 text-[14px] text-text-primary max-w-[240px] truncate">
                    {email.subject}
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    </div>
  );
}
