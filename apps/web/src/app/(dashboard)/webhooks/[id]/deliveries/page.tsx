"use client";

import { useState, useEffect, useCallback } from "react";
import { useRouter, useParams } from "next/navigation";
import { api } from "@/lib/api";
import { PER_PAGE_DEFAULT } from "@/lib/constants";
import { PageShell } from "@/components/layout/PageShell";
import { Badge } from "@/components/ui/Badge";
import { Skeleton } from "@/components/ui/Skeleton";
import { Pagination } from "@/components/ui/Pagination";
import { Button } from "@/components/ui/Button";
import { Modal } from "@/components/ui/Modal";
import { EmptyState } from "@/components/ui/EmptyState";
import { useToast } from "@/components/ui/Toast";
import { ArrowLeft, Webhook, RotateCcw, CheckCircle2, XCircle, Clock, Code, Eye } from "lucide-react";

function formatDate(dateStr: string) {
  return new Date(dateStr).toLocaleString();
}

const STATUS_VARIANTS: Record<string, "success" | "danger" | "warning" | "info" | "neutral"> = {
  delivered: "success",
  failed: "danger",
  pending: "warning",
};

export default function WebhookDeliveriesPage() {
  const router = useRouter();
  const params = useParams();
  const { toast } = useToast();
  const [data, setData] = useState<any[]>([]);
  const [meta, setMeta] = useState({ page: 1, perPage: PER_PAGE_DEFAULT, total: 0, pages: 0 });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [replaying, setReplaying] = useState<string | null>(null);
  const [inspecting, setInspecting] = useState<any | null>(null);

  const fetchDeliveries = useCallback(async (page: number) => {
    setLoading(true);
    setError("");
    try {
      const paramsStr = new URLSearchParams({ page: String(page), perPage: String(PER_PAGE_DEFAULT) });
      const res: any = await api.get(`/webhooks/${params.id}/deliveries?${paramsStr}`);
      setData(res.data || []);
      setMeta(res.meta || { page, perPage: PER_PAGE_DEFAULT, total: 0, pages: 0 });
    } catch (e: any) {
      setError(e.message || "Failed to load deliveries");
    } finally {
      setLoading(false);
    }
  }, [params.id]);

  useEffect(() => {
    if (params.id) fetchDeliveries(1);
  }, [params.id, fetchDeliveries]);

  const handleReplay = async (deliveryId: string) => {
    setReplaying(deliveryId);
    try {
      await api.post(`/webhooks/${params.id}/replay/${deliveryId}`);
      toast({ type: "success", title: "Webhook re-queued" });
      fetchDeliveries(meta.page);
    } catch (e: any) {
      toast({ type: "error", title: "Failed to replay", message: e.message });
    } finally {
      setReplaying(null);
    }
  };

  return (
    <PageShell
      title="Webhook Deliveries"
      subtitle={`${meta.total} total deliveries`}
      actions={
        <Button variant="ghost" onClick={() => router.push("/webhooks")} icon={<ArrowLeft className="h-4 w-4" />}>
          Back
        </Button>
      }
    >
      {error && (
        <div className="glass-sm p-4 mb-6 text-danger flex items-center justify-between">
          <span>{error}</span>
          <Button variant="ghost" size="sm" onClick={() => fetchDeliveries(meta.page)}>Retry</Button>
        </div>
      )}

      {loading ? (
        <div className="glass rounded-[16px] overflow-hidden">
          {Array.from({ length: 5 }).map((_, i) => (
            <div key={i} className="flex items-center gap-4 px-5 py-4 border-b border-[rgba(0,0,0,0.04)]">
              <Skeleton className="h-4 w-32" />
              <Skeleton className="h-5 w-20 rounded-full" />
              <Skeleton className="h-4 w-24" />
              <Skeleton className="h-4 w-16 ml-auto" />
            </div>
          ))}
        </div>
      ) : data.length === 0 ? (
        <EmptyState
          icon={<Webhook className="h-10 w-10" />}
          title="No deliveries yet"
          description="Webhook deliveries will appear here when events are triggered."
          action={{ label: "Back to Webhooks", onClick: () => router.push("/webhooks") }}
        />
      ) : (
        <>
          <div className="glass rounded-[16px] overflow-hidden animate-fade-in">
            <div className="grid grid-cols-[1fr_auto_auto_auto_auto_auto] gap-4 px-5 py-3 text-[13px] font-medium text-text-secondary border-b border-[rgba(0,0,0,0.04)]">
              <span>Event</span>
              <span>Status</span>
              <span>Attempts</span>
              <span>Response</span>
              <span>Date</span>
              <span></span>
            </div>
            {data.map((d: any) => {
              const isDelivered = !!d.delivered_at;
              const isFailed = !!d.error_message || d.response_status >= 400;
              const status = isDelivered ? "delivered" : isFailed ? "failed" : "pending";
              const sv = STATUS_VARIANTS[status] || "neutral";
              return (
                <div key={d.id} className="grid grid-cols-[1fr_auto_auto_auto_auto_auto] gap-4 px-5 py-3.5 border-b border-[rgba(0,0,0,0.04)] last:border-0 hover:bg-accent-glass transition-colors items-center text-[15px]">
                  <span className="text-text-primary truncate">
                    <Badge variant="info">{d.event_type}</Badge>
                  </span>
                  <span className="flex items-center gap-1.5">
                    {isDelivered ? <CheckCircle2 className="h-4 w-4 text-success" /> : isFailed ? <XCircle className="h-4 w-4 text-danger" /> : <Clock className="h-4 w-4 text-warning" />}
                    <Badge variant={sv} dot>{status}</Badge>
                  </span>
                  <span className="text-text-tertiary text-[13px]">{d.attempt}/10</span>
                  <span className="text-text-tertiary text-[13px] font-mono">{d.response_status || "-"}</span>
                  <span className="text-text-tertiary text-[13px]">{formatDate(d.created_at)}</span>
                  <span className="flex items-center gap-1">
                    <Button
                      size="sm"
                      variant="ghost"
                      onClick={() => setInspecting(d)}
                      icon={<Eye className="h-3.5 w-3.5" />}
                    >
                      Inspect
                    </Button>
                    {isFailed && (
                      <Button
                        size="sm"
                        variant="ghost"
                        loading={replaying === d.id}
                        onClick={() => handleReplay(d.id)}
                        icon={<RotateCcw className="h-3.5 w-3.5" />}
                      >
                        Replay
                      </Button>
                    )}
                  </span>
                </div>
              );
            })}
          </div>
          {meta.pages > 1 && (
            <Pagination page={meta.page} perPage={meta.perPage} total={meta.total} onChange={(p) => fetchDeliveries(p)} />
          )}
        </>
      )}

      <Modal open={!!inspecting} onClose={() => setInspecting(null)} title="Webhook Delivery Inspector">
        {inspecting && (
          <div className="space-y-4">
            <div className="grid grid-cols-2 gap-3 text-[14px]">
              <div>
                <span className="text-text-tertiary">Event Type:</span>
                <p className="font-medium">{inspecting.event_type}</p>
              </div>
              <div>
                <span className="text-text-tertiary">Status:</span>
                <p className="font-medium">
                  <Badge variant={inspecting.delivered_at ? "success" : inspecting.error_message ? "danger" : "warning"}>
                    {inspecting.delivered_at ? "Delivered" : inspecting.error_message ? "Failed" : "Pending"}
                  </Badge>
                </p>
              </div>
              <div>
                <span className="text-text-tertiary">Attempt:</span>
                <p className="font-medium">{inspecting.attempt}/10</p>
              </div>
              <div>
                <span className="text-text-tertiary">Response Status:</span>
                <p className="font-medium">{inspecting.response_status || "-"}</p>
              </div>
            </div>

            {inspecting.error_message && (
              <div>
                <p className="text-[13px] text-text-tertiary mb-1">Error Message</p>
                <div className="glass-sm p-3 rounded-lg text-[13px] text-danger font-mono whitespace-pre-wrap break-all">
                  {inspecting.error_message}
                </div>
              </div>
            )}

            {inspecting.response_body && (
              <div>
                <p className="text-[13px] text-text-tertiary mb-1 flex items-center gap-1.5">
                  <Code className="h-3.5 w-3.5" /> Response Body
                </p>
                <pre className="glass-sm p-3 rounded-lg text-[12px] text-text-primary font-mono whitespace-pre-wrap overflow-x-auto max-h-48">
                  {(() => {
                    try { return JSON.stringify(JSON.parse(inspecting.response_body), null, 2); }
                    catch { return inspecting.response_body; }
                  })()}
                </pre>
              </div>
            )}

            {inspecting.payload && (
              <div>
                <p className="text-[13px] text-text-tertiary mb-1 flex items-center gap-1.5">
                  <Code className="h-3.5 w-3.5" /> Payload
                </p>
                <pre className="glass-sm p-3 rounded-lg text-[12px] text-text-primary font-mono whitespace-pre-wrap overflow-x-auto max-h-48">
                  {typeof inspecting.payload === "string" ? inspecting.payload : JSON.stringify(inspecting.payload, null, 2)}
                </pre>
              </div>
            )}

            <div className="text-[12px] text-text-tertiary">
              Created: {formatDate(inspecting.created_at)}
              {inspecting.delivered_at && <> | Delivered: {formatDate(inspecting.delivered_at)}</>}
              {inspecting.failed_at && <> | Failed: {formatDate(inspecting.failed_at)}</>}
            </div>
          </div>
        )}
      </Modal>
    </PageShell>
  );
}
