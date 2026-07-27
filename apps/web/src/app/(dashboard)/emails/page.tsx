"use client";

import { useState, useEffect, useCallback } from "react";
import { useRouter } from "next/navigation";
import { api } from "@/lib/api";
import { EMAIL_STATUSES, PER_PAGE_DEFAULT } from "@/lib/constants";
import { PageShell } from "@/components/layout/PageShell";
import { Button } from "@/components/ui/Button";
import { Badge } from "@/components/ui/Badge";
import { Skeleton } from "@/components/ui/Skeleton";
import { Pagination } from "@/components/ui/Pagination";
import { EmptyState } from "@/components/ui/EmptyState";
import { Select } from "@/components/ui/Select";
import { Send, Plus, Search } from "lucide-react";

const statusBadge: Record<string, { variant: "success" | "warning" | "danger" | "info"; label: string }> = {
  queued: { variant: "warning", label: "Queued" },
  sending: { variant: "info", label: "Sending" },
  delivered: { variant: "success", label: "Delivered" },
  bounced: { variant: "danger", label: "Bounced" },
  opened: { variant: "info", label: "Opened" },
  clicked: { variant: "success", label: "Clicked" },
  complained: { variant: "danger", label: "Complained" },
};

function relativeTime(date: string): string {
  const diff = Date.now() - new Date(date).getTime();
  const mins = Math.floor(diff / 60000);
  if (mins < 1) return "just now";
  if (mins < 60) return `${mins}m ago`;
  const hrs = Math.floor(mins / 60);
  if (hrs < 24) return `${hrs}h ago`;
  const days = Math.floor(hrs / 24);
  return `${days}d ago`;
}

function truncate(str: string, len: number): string {
  return str.length > len ? str.slice(0, len) + "\u2026" : str;
}

export default function EmailsPage() {
  const router = useRouter();
  const [data, setData] = useState<any[]>([]);
  const [meta, setMeta] = useState({ page: 1, perPage: PER_PAGE_DEFAULT, total: 0, pages: 0 });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [status, setStatus] = useState("");
  const [search, setSearch] = useState("");

  const fetchEmails = useCallback(async (page: number) => {
    setLoading(true);
    setError("");
    try {
      const params = new URLSearchParams({ page: String(page), perPage: String(PER_PAGE_DEFAULT) });
      if (status) params.set("status", status);
      const res: any = await api.get(`/emails?${params}`);
      setData(res.data || []);
      setMeta(res.meta || { page, perPage: PER_PAGE_DEFAULT, total: 0, pages: 0 });
    } catch (e: any) {
      setError(e.message || "Failed to load emails");
    } finally {
      setLoading(false);
    }
  }, [status]);

  useEffect(() => { fetchEmails(1); }, [fetchEmails]);

  return (
    <PageShell
      title="Emails"
      subtitle={`${meta.total} total emails`}
      actions={
        <Button onClick={() => router.push("/emails/new")} icon={<Plus className="h-4 w-4" />}>
          Compose
        </Button>
      }
    >
      {error && (
        <div className="glass-sm p-4 mb-6 text-danger flex items-center justify-between">
          <span>{error}</span>
          <Button variant="ghost" size="sm" onClick={() => fetchEmails(meta.page)}>Retry</Button>
        </div>
      )}

      <div className="flex items-center gap-3 mb-6">
        <div className="relative flex-1 max-w-xs">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-text-tertiary" />
          <input
            className="input-glass w-full pl-9 pr-3 py-2 text-[15px] text-text-primary placeholder:text-text-tertiary"
            placeholder="Search by email or subject..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
        </div>
        <Select
          options={[{ value: "", label: "All statuses" }, ...EMAIL_STATUSES.map((s) => ({ value: s, label: s.charAt(0).toUpperCase() + s.slice(1) }))]}
          value={status}
          onChange={(v) => setStatus(v)}
        />
      </div>

      {loading ? (
        <div className="glass rounded-[16px] overflow-hidden">
          {Array.from({ length: 8 }).map((_, i) => (
            <div key={i} className="flex items-center gap-4 px-5 py-4 border-b border-[rgba(0,0,0,0.04)]">
              <Skeleton className="h-4 w-40" />
              <Skeleton className="h-4 w-56" />
              <Skeleton className="h-5 w-20 rounded-full" />
              <Skeleton className="h-4 w-16 ml-auto" />
            </div>
          ))}
        </div>
      ) : data.length === 0 ? (
        <EmptyState
          icon={<Send className="h-10 w-10" />}
          title="No emails sent yet"
          description="Your first email is just a click away."
          action={{ label: "Send your first email", onClick: () => router.push("/emails/new") }}
        />
      ) : (
        <>
          <div className="glass rounded-[16px] overflow-hidden animate-fade-in">
            <div className="grid grid-cols-[1fr_2fr_auto_auto] gap-4 px-5 py-3 text-[13px] font-medium text-text-secondary border-b border-[rgba(0,0,0,0.04)]">
              <span>To</span>
              <span>Subject</span>
              <span>Status</span>
              <span>Sent</span>
            </div>
            {data.map((email: any) => {
              const sb = statusBadge[email.status] || { variant: "neutral" as const, label: email.status };
              return (
                <div
                  key={email.id}
                  className="grid grid-cols-[1fr_2fr_auto_auto] gap-4 px-5 py-3.5 border-b border-[rgba(0,0,0,0.04)] last:border-0 hover:bg-accent-glass cursor-pointer transition-colors items-center text-[15px]"
                  onClick={() => router.push(`/emails/${email.id}`)}
                >
                  <span className="text-text-primary truncate">{truncate(email.to_address, 30)}</span>
                  <span className="text-text-primary truncate">{truncate(email.subject || "(no subject)", 50)}</span>
                  <Badge variant={sb.variant as any} dot>{sb.label}</Badge>
                  <span className="text-text-tertiary text-[13px]">{relativeTime(email.created_at)}</span>
                </div>
              );
            })}
          </div>
          {meta.pages > 1 && (
            <Pagination page={meta.page} perPage={meta.perPage} total={meta.total} onChange={(p) => fetchEmails(p)} />
          )}
        </>
      )}
    </PageShell>
  );
}
