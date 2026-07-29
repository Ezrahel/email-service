"use client";

import { useState, useEffect, useCallback } from "react";
import { useRouter } from "next/navigation";
import { clsx } from "clsx";
import { api } from "@/lib/api";
import { WEBHOOK_EVENTS } from "@/lib/constants";
import { PageShell } from "@/components/layout/PageShell";
import { Button } from "@/components/ui/Button";
import { Badge } from "@/components/ui/Badge";
import { Skeleton } from "@/components/ui/Skeleton";
import { Modal } from "@/components/ui/Modal";
import { Dialog } from "@/components/ui/Dialog";
import { Input } from "@/components/ui/Input";
import { CopyButton } from "@/components/ui/CopyButton";
import { EmptyState } from "@/components/ui/EmptyState";
import { useToast } from "@/components/ui/Toast";
import { Plus, Webhook, Trash2, Activity, RefreshCw, List, AlertTriangle } from "lucide-react";

function formatDate(dateStr: string) {
  return new Date(dateStr).toLocaleDateString();
}

interface WebhookData {
  id: string;
  url: string;
  events: string[];
  status: string;
  failure_count: number;
  created_at: string;
}

export default function WebhooksPage() {
  const router = useRouter();
  const { toast } = useToast();
  const [data, setData] = useState<WebhookData[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [createOpen, setCreateOpen] = useState(false);
  const [webhookUrl, setWebhookUrl] = useState("");
  const [selectedEvents, setSelectedEvents] = useState<string[]>([]);
  const [webhookSecret, setWebhookSecret] = useState("");
  const [creating, setCreating] = useState(false);
  const [deleteTarget, setDeleteTarget] = useState<WebhookData | null>(null);
  const [deleting, setDeleting] = useState(false);
  const [rotateTarget, setRotateTarget] = useState<WebhookData | null>(null);
  const [rotating, setRotating] = useState(false);
  const [newSecret, setNewSecret] = useState<string | null>(null);

  const fetchWebhooks = useCallback(async () => {
    setLoading(true);
    setError("");
    try {
      const res: any = await api.get("/webhooks");
      setData(res || []);
    } catch (e: any) {
      setError(e.message || "Failed to load webhooks");
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => { fetchWebhooks(); }, [fetchWebhooks]);

  const toggleEvent = (event: string) => {
    setSelectedEvents((prev) =>
      prev.includes(event) ? prev.filter((e) => e !== event) : [...prev, event],
    );
  };

  const handleCreate = async () => {
    if (!webhookUrl.trim()) return;
    setCreating(true);
    try {
      await api.post("/webhooks", {
        url: webhookUrl.trim(),
        events: selectedEvents,
        secret: webhookSecret.trim() || undefined,
      });
      toast({ type: "success", title: "Webhook created" });
      setCreateOpen(false);
      setWebhookUrl("");
      setSelectedEvents([]);
      setWebhookSecret("");
      fetchWebhooks();
    } catch (e: any) {
      toast({ type: "error", title: "Failed to create webhook", message: e.message });
    } finally {
      setCreating(false);
    }
  };

  const handleRotate = async () => {
    if (!rotateTarget) return;
    setRotating(true);
    try {
      const res: any = await api.post(`/webhooks/${rotateTarget.id}/rotate-secret`);
      setNewSecret(res.secret);
      toast({ type: "success", title: "Secret rotated" });
      fetchWebhooks();
    } catch (e: any) {
      toast({ type: "error", title: "Failed to rotate secret", message: e.message });
    } finally {
      setRotating(false);
    }
  };

  const closeRotate = () => {
    setRotateTarget(null);
    setNewSecret(null);
  };

  const handleDelete = async () => {
    if (!deleteTarget) return;
    setDeleting(true);
    try {
      await api.delete(`/webhooks/${deleteTarget.id}`);
      toast({ type: "success", title: "Webhook deleted" });
      setDeleteTarget(null);
      fetchWebhooks();
    } catch (e: any) {
      toast({ type: "error", title: "Failed to delete", message: e.message });
    } finally {
      setDeleting(false);
    }
  };

  return (
    <PageShell
      title="Webhooks"
      actions={
        <Button onClick={() => setCreateOpen(true)} icon={<Plus className="h-4 w-4" />}>
          Create
        </Button>
      }
    >
      {error && (
        <div className="glass-sm p-4 mb-6 text-danger flex items-center justify-between">
          <span>{error}</span>
          <Button variant="ghost" size="sm" onClick={fetchWebhooks}>Retry</Button>
        </div>
      )}

      {loading ? (
        <div className="flex flex-col gap-4">
          {Array.from({ length: 3 }).map((_, i) => (
            <div key={i} className="glass p-5">
              <div className="flex items-center gap-3">
                <Skeleton className="h-5 w-5 rounded" />
                <div className="flex-1">
                  <Skeleton className="h-5 w-56 mb-1" />
                  <Skeleton className="h-4 w-32" />
                </div>
              </div>
            </div>
          ))}
        </div>
      ) : data.length === 0 ? (
        <EmptyState
          icon={<Webhook className="h-10 w-10" />}
          title="No webhooks configured"
          description="Create webhooks to receive real-time email event notifications."
          action={{ label: "Create Webhook", onClick: () => setCreateOpen(true) }}
        />
      ) : (
        <div className="flex flex-col gap-4">
          {data.map((wh) => (
            <div key={wh.id} className="glass p-5 animate-fade-in">
              <div className="flex items-start justify-between">
                <div className="flex items-center gap-3 min-w-0">
                  <Webhook className="h-5 w-5 text-text-secondary shrink-0 mt-0.5" />
                  <div className="min-w-0">
                    <p className="text-[15px] font-medium text-text-primary truncate max-w-md">{wh.url}</p>
                    <div className="flex items-center gap-2 mt-1.5 flex-wrap">
                      <Badge variant={wh.status === "active" ? "success" : "danger"} dot>
                        {wh.status}
                      </Badge>
                      {wh.events.map((ev) => (
                        <Badge key={ev} variant="info">{ev}</Badge>
                      ))}
                      <span className="text-[13px] text-text-tertiary">
                        Created {formatDate(wh.created_at)}
                      </span>
                      {wh.failure_count > 0 && (
                        <span className="text-[13px] text-danger flex items-center gap-1">
                          <Activity className="h-3.5 w-3.5" />
                          {wh.failure_count} failures
                        </span>
                      )}
                    </div>
                  </div>
                </div>
                <div className="flex items-center gap-1 shrink-0">
                  <Button
                    size="sm"
                    variant="ghost"
                    className="text-text-tertiary hover:text-accent"
                    onClick={() => router.push(`/webhooks/${wh.id}/deliveries`)}
                    title="View deliveries"
                  >
                    <List className="h-4 w-4" />
                  </Button>
                  <Button
                    size="sm"
                    variant="ghost"
                    className="text-text-tertiary hover:text-accent"
                    onClick={() => { setRotateTarget(wh); setNewSecret(null); }}
                    title="Rotate secret"
                  >
                    <RefreshCw className="h-4 w-4" />
                  </Button>
                  <Button
                    size="sm"
                    variant="ghost"
                    className="text-text-tertiary hover:text-danger"
                    onClick={() => setDeleteTarget(wh)}
                  >
                    <Trash2 className="h-4 w-4" />
                  </Button>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      <Modal open={createOpen} onClose={() => setCreateOpen(false)} title="Create Webhook">
        <div className="flex flex-col gap-4">
          <Input label="URL" placeholder="https://api.example.com/webhook" value={webhookUrl} onChange={(e) => setWebhookUrl(e.target.value)} />
          <div>
            <p className="text-[13px] font-medium text-text-secondary mb-2">Events</p>
            <div className="flex flex-wrap gap-2">
              {WEBHOOK_EVENTS.map((event) => (
                <button
                  key={event}
                  type="button"
                  onClick={() => toggleEvent(event)}
                  className={clsx(
                    "px-3 py-1.5 rounded-lg text-[13px] font-medium transition-colors border",
                    selectedEvents.includes(event)
                      ? "bg-accent text-white border-accent"
                      : "bg-transparent text-text-secondary border-[rgba(0,0,0,0.1)] hover:border-accent hover:text-accent",
                  )}
                >
                  {event}
                </button>
              ))}
            </div>
          </div>
          <Input label="Secret (optional)" type="password" placeholder="webhook secret" value={webhookSecret} onChange={(e) => setWebhookSecret(e.target.value)} />
          <div className="flex items-center justify-end gap-3 pt-2">
            <Button variant="secondary" onClick={() => setCreateOpen(false)}>Cancel</Button>
            <Button onClick={handleCreate} loading={creating}>Create</Button>
          </div>
        </div>
      </Modal>

      <Modal open={!!rotateTarget} onClose={closeRotate} title="Rotate Webhook Secret">
        {newSecret ? (
          <div className="flex flex-col gap-4">
            <div className="glass-sm p-4 flex items-start gap-3 bg-warning/10 border border-warning/20 rounded-lg">
              <AlertTriangle className="h-5 w-5 text-warning shrink-0 mt-0.5" />
              <div>
                <p className="text-[14px] font-medium text-warning">Copy this secret now</p>
                <p className="text-[13px] text-text-secondary mt-0.5">You won&apos;t be able to see it again after closing this dialog.</p>
              </div>
            </div>
            <div className="flex items-center gap-2 bg-[rgba(0,0,0,0.03)] p-3 rounded-lg">
              <code className="flex-1 text-[14px] font-mono text-text-primary break-all">{newSecret}</code>
              <CopyButton value={newSecret} />
            </div>
            <div className="flex justify-end pt-2">
              <Button onClick={closeRotate}>Done</Button>
            </div>
          </div>
        ) : (
          <div className="flex flex-col gap-4">
            <p className="text-[14px] text-text-secondary">
              Rotate the secret for <strong>{rotateTarget?.url}</strong>? The current secret will be immediately invalidated.
            </p>
            <div className="flex items-center justify-end gap-3 pt-2">
              <Button variant="secondary" onClick={closeRotate}>Cancel</Button>
              <Button onClick={handleRotate} loading={rotating}>Rotate</Button>
            </div>
          </div>
        )}
      </Modal>

      <Dialog
        open={!!deleteTarget}
        onClose={() => setDeleteTarget(null)}
        title="Delete Webhook"
        message={`Are you sure you want to delete the webhook at ${deleteTarget?.url || ""}? This action cannot be undone.`}
        confirmLabel="Delete"
        variant="danger"
        loading={deleting}
        onConfirm={handleDelete}
      />
    </PageShell>
  );
}
