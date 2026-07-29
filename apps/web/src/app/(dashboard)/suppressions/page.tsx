"use client";

import { useState, useEffect, useCallback } from "react";
import { api } from "@/lib/api";
import { PER_PAGE_DEFAULT } from "@/lib/constants";
import { PageShell } from "@/components/layout/PageShell";
import { Button } from "@/components/ui/Button";
import { Badge } from "@/components/ui/Badge";
import { Skeleton } from "@/components/ui/Skeleton";
import { Pagination } from "@/components/ui/Pagination";
import { EmptyState } from "@/components/ui/EmptyState";
import { Modal } from "@/components/ui/Modal";
import { Dialog } from "@/components/ui/Dialog";
import { Input } from "@/components/ui/Input";
import { Select } from "@/components/ui/Select";
import { useToast } from "@/components/ui/Toast";
import { Ban, Plus, Trash2 } from "lucide-react";

const REASON_BADGE: Record<string, { variant: "danger" | "warning" | "info" | "neutral"; label: string }> = {
  hard_bounce: { variant: "danger", label: "Hard Bounce" },
  complaint: { variant: "warning", label: "Complaint" },
  manual: { variant: "info", label: "Manual" },
  unsubscribed: { variant: "neutral", label: "Unsubscribed" },
};

function formatDate(dateStr: string) {
  return new Date(dateStr).toLocaleDateString();
}

export default function SuppressionsPage() {
  const { toast } = useToast();
  const [data, setData] = useState<any[]>([]);
  const [meta, setMeta] = useState({ page: 1, perPage: PER_PAGE_DEFAULT, total: 0, pages: 0 });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [reasonFilter, setReasonFilter] = useState("");

  const [createOpen, setCreateOpen] = useState(false);
  const [suppressEmail, setSuppressEmail] = useState("");
  const [suppressReason, setSuppressReason] = useState("manual");
  const [creating, setCreating] = useState(false);

  const [removeTarget, setRemoveTarget] = useState<any | null>(null);
  const [removing, setRemoving] = useState(false);

  const fetchSuppressions = useCallback(async (page: number) => {
    setLoading(true);
    setError("");
    try {
      const params = new URLSearchParams({ page: String(page), perPage: String(PER_PAGE_DEFAULT) });
      if (reasonFilter) params.set("reason", reasonFilter);
      const res: any = await api.get(`/suppressions?${params}`);
      setData(res.data || []);
      setMeta(res.meta || { page, perPage: PER_PAGE_DEFAULT, total: 0, pages: 0 });
    } catch (e: any) {
      setError(e.message || "Failed to load suppressions");
    } finally {
      setLoading(false);
    }
  }, [reasonFilter]);

  useEffect(() => { fetchSuppressions(1); }, [fetchSuppressions]);

  const handleCreate = async () => {
    if (!suppressEmail.trim()) return;
    setCreating(true);
    try {
      await api.post("/suppressions", { email: suppressEmail.trim(), reason: suppressReason });
      toast({ type: "success", title: "Email suppressed" });
      setCreateOpen(false);
      setSuppressEmail("");
      setSuppressReason("manual");
      fetchSuppressions(1);
    } catch (e: any) {
      toast({ type: "error", title: "Failed to suppress", message: e.message });
    } finally {
      setCreating(false);
    }
  };

  const handleRemove = async () => {
    if (!removeTarget) return;
    setRemoving(true);
    try {
      await api.delete(`/suppressions/${removeTarget.id}`);
      toast({ type: "success", title: "Suppression removed" });
      setRemoveTarget(null);
      fetchSuppressions(meta.page);
    } catch (e: any) {
      toast({ type: "error", title: "Failed to remove", message: e.message });
    } finally {
      setRemoving(false);
    }
  };

  return (
    <PageShell
      title="Suppressions"
      subtitle={`${meta.total} suppressed emails`}
      actions={
        <Button onClick={() => setCreateOpen(true)} icon={<Plus className="h-4 w-4" />}>
          Add Suppression
        </Button>
      }
    >
      {error && (
        <div className="glass-sm p-4 mb-6 text-danger flex items-center justify-between">
          <span>{error}</span>
          <Button variant="ghost" size="sm" onClick={() => fetchSuppressions(meta.page)}>Retry</Button>
        </div>
      )}

      <div className="flex items-center gap-3 mb-6">
        <Select
          options={[
            { value: "", label: "All reasons" },
            { value: "hard_bounce", label: "Hard Bounce" },
            { value: "complaint", label: "Complaint" },
            { value: "manual", label: "Manual" },
            { value: "unsubscribed", label: "Unsubscribed" },
          ]}
          value={reasonFilter}
          onChange={(v) => setReasonFilter(v)}
        />
      </div>

      {loading ? (
        <div className="glass rounded-[16px] overflow-hidden">
          {Array.from({ length: 5 }).map((_, i) => (
            <div key={i} className="flex items-center gap-4 px-5 py-4 border-b border-[rgba(0,0,0,0.04)]">
              <Skeleton className="h-4 w-48" />
              <Skeleton className="h-5 w-24 rounded-full" />
              <Skeleton className="h-4 w-20 ml-auto" />
            </div>
          ))}
        </div>
      ) : data.length === 0 ? (
        <EmptyState
          icon={<Ban className="h-10 w-10" />}
          title="No suppressions"
          description="Suppressed emails will not receive any future emails from your account."
          action={{ label: "Add Suppression", onClick: () => setCreateOpen(true) }}
        />
      ) : (
        <>
          <div className="glass rounded-[16px] overflow-hidden animate-fade-in">
            <div className="grid grid-cols-[1fr_auto_auto_auto] gap-4 px-5 py-3 text-[13px] font-medium text-text-secondary border-b border-[rgba(0,0,0,0.04)]">
              <span>Email</span>
              <span>Reason</span>
              <span>Date</span>
              <span></span>
            </div>
            {data.map((item: any) => {
              const rb = REASON_BADGE[item.reason] || { variant: "neutral" as const, label: item.reason };
              return (
                <div key={item.id} className="grid grid-cols-[1fr_auto_auto_auto] gap-4 px-5 py-3.5 border-b border-[rgba(0,0,0,0.04)] last:border-0 hover:bg-accent-glass transition-colors items-center text-[15px]">
                  <span className="text-text-primary truncate">{item.email}</span>
                  <Badge variant={rb.variant as any}>{rb.label}</Badge>
                  <span className="text-text-tertiary text-[13px]">{formatDate(item.created_at)}</span>
                  <Button
                    size="sm"
                    variant="ghost"
                    className="text-text-tertiary hover:text-danger"
                    onClick={() => setRemoveTarget(item)}
                  >
                    <Trash2 className="h-4 w-4" />
                  </Button>
                </div>
              );
            })}
          </div>
          {meta.pages > 1 && (
            <Pagination page={meta.page} perPage={meta.perPage} total={meta.total} onChange={(p) => fetchSuppressions(p)} />
          )}
        </>
      )}

      <Modal open={createOpen} onClose={() => setCreateOpen(false)} title="Add Suppression">
        <div className="flex flex-col gap-4">
          <Input label="Email Address" placeholder="bounce@example.com" value={suppressEmail} onChange={(e) => setSuppressEmail(e.target.value)} />
          <Select
            label="Reason"
            options={[
              { value: "manual", label: "Manual" },
              { value: "hard_bounce", label: "Hard Bounce" },
              { value: "complaint", label: "Complaint" },
              { value: "unsubscribed", label: "Unsubscribed" },
            ]}
            value={suppressReason}
            onChange={(v) => setSuppressReason(v)}
          />
          <div className="flex items-center justify-end gap-3 pt-2">
            <Button variant="secondary" onClick={() => setCreateOpen(false)}>Cancel</Button>
            <Button onClick={handleCreate} loading={creating}>Suppress</Button>
          </div>
        </div>
      </Modal>

      <Dialog
        open={!!removeTarget}
        onClose={() => setRemoveTarget(null)}
        title="Remove Suppression"
        message={`Remove suppression for "${removeTarget?.email || ""}"? This email will be able to receive emails again.`}
        confirmLabel="Remove"
        variant="danger"
        loading={removing}
        onConfirm={handleRemove}
      />
    </PageShell>
  );
}
