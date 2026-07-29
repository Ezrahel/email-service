"use client";

import { useState, useEffect } from "react";
import { useRouter, useParams } from "next/navigation";
import { api } from "@/lib/api";
import { PageShell } from "@/components/layout/PageShell";
import { Badge } from "@/components/ui/Badge";
import { Skeleton } from "@/components/ui/Skeleton";
import { Button } from "@/components/ui/Button";
import { Tabs } from "@/components/ui/Tabs";
import { useToast } from "@/components/ui/Toast";
import { DeliveryTimeline } from "@/components/emails/DeliveryTimeline";
import { EmailStatusBadge } from "@/components/emails/EmailStatusBadge";
import { ArrowLeft, AlertCircle, XCircle, Paperclip } from "lucide-react";

function formatDate(dateStr: string) {
  return new Date(dateStr).toLocaleString();
}

interface Delivery {
  id: string;
  provider: string;
  status: string;
  attempts: number;
  response_code: string;
  created_at: string;
  completed_at?: string;
}

interface EmailData {
  id: string;
  from_address: string;
  to_address: string;
  subject: string;
  status: string;
  html_body: string;
  text_body: string;
  tags: string[];
  environment?: string;
  scheduled_at?: string;
  created_at: string;
  deliveries: Delivery[];
  attachments?: Array<{ id: string; filename: string; content_type: string; size: number }>;
  metrics?: { is_opened?: boolean; is_clicked?: boolean; is_complained?: boolean; open_count?: number; click_count?: number };
}

export default function EmailDetailPage() {
  const router = useRouter();
  const params = useParams();
  const { toast } = useToast();
  const [data, setData] = useState<EmailData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [activeTab, setActiveTab] = useState("html");
  const [cancelling, setCancelling] = useState(false);

  const fetchEmail = async () => {
    setLoading(true);
    setError("");
    try {
      const res: any = await api.get(`/emails/${params.id}`);
      setData(res);
    } catch (e: any) {
      setError(e.message || "Email not found");
    } finally {
      setLoading(false);
    }
  };

  const handleCancel = async () => {
    setCancelling(true);
    try {
      await api.post(`/emails/${params.id}/cancel`);
      toast({ type: "success", title: "Email cancelled" });
      fetchEmail();
    } catch (e: any) {
      toast({ type: "error", title: "Failed to cancel", message: e.message });
    } finally {
      setCancelling(false);
    }
  };

  useEffect(() => {
    if (params.id) fetchEmail();
  }, [params.id]);

  if (loading) {
    return (
      <PageShell title="Email Detail" actions={<Button variant="ghost" onClick={() => router.push("/emails")} icon={<ArrowLeft className="h-4 w-4" />}>Back</Button>}>
        <div className="flex flex-col gap-5">
          <Skeleton className="h-10 w-48 rounded-full" />
          <Skeleton className="h-32 w-full" />
          <Skeleton className="h-24 w-full" />
          <Skeleton className="h-20 w-full" />
          <Skeleton className="h-64 w-full" />
        </div>
      </PageShell>
    );
  }

  if (error || !data) {
    return (
      <PageShell title="Email Detail" actions={<Button variant="ghost" onClick={() => router.push("/emails")} icon={<ArrowLeft className="h-4 w-4" />}>Back</Button>}>
        <div className="glass p-8 flex flex-col items-center text-center max-w-md mx-auto">
          <AlertCircle className="h-10 w-10 text-danger mb-3" />
          <p className="text-[15px] text-danger mb-4">{error || "Email not found"}</p>
          <Button variant="secondary" onClick={() => router.push("/emails")}>Back to Emails</Button>
        </div>
      </PageShell>
    );
  }

  return (
    <PageShell
      title="Email Detail"
      actions={
        <div className="flex items-center gap-2">
          {data.status === "scheduled" && (
            <Button variant="danger" size="sm" loading={cancelling} onClick={handleCancel} icon={<XCircle className="h-4 w-4" />}>
              Cancel Send
            </Button>
          )}
          <Button variant="ghost" onClick={() => router.push("/emails")} icon={<ArrowLeft className="h-4 w-4" />}>Back</Button>
        </div>
      }
    >
      <div className="flex flex-col gap-5 max-w-4xl">
        <div className="flex items-center gap-3">
          <EmailStatusBadge status={data.status} />
          {data.environment === "sandbox" && <Badge variant="warning">Sandbox</Badge>}
        </div>
        <div className="flex items-center gap-2 text-[14px] text-text-secondary -mt-3">
          <span>{data.scheduled_at ? `Scheduled: ${formatDate(data.scheduled_at)}` : formatDate(data.created_at)}</span>
        </div>

        <div className="glass p-5 grid grid-cols-2 gap-4">
          <div>
            <p className="text-[13px] text-text-tertiary mb-0.5">From</p>
            <p className="text-[15px] text-text-primary">{data.from_address}</p>
          </div>
          <div>
            <p className="text-[13px] text-text-tertiary mb-0.5">To</p>
            <p className="text-[15px] text-text-primary">{data.to_address}</p>
          </div>
          <div>
            <p className="text-[13px] text-text-tertiary mb-0.5">Subject</p>
            <p className="text-[15px] text-text-primary">{data.subject || "(no subject)"}</p>
          </div>
          <div>
            <p className="text-[13px] text-text-tertiary mb-0.5">Sent</p>
            <p className="text-[15px] text-text-primary">{formatDate(data.created_at)}</p>
          </div>
          {data.tags && data.tags.length > 0 && (
            <div className="col-span-2">
              <p className="text-[13px] text-text-tertiary mb-0.5">Tags</p>
              <div className="flex flex-wrap gap-1.5 mt-1">
                {data.tags.map((tag) => (
                  <Badge key={tag}>{tag}</Badge>
                ))}
              </div>
            </div>
          )}
        </div>

        <DeliveryTimeline deliveries={data.deliveries} status={data.status} metrics={data.metrics} scheduledAt={data.scheduled_at} />

        {data.metrics && (data.metrics.open_count !== undefined || data.metrics.click_count !== undefined) && (
          <div className="glass p-5">
            <h3 className="text-[15px] font-semibold text-text-primary mb-4">Tracking Stats</h3>
            <div className="flex items-center gap-6">
              <div className="flex items-center gap-3">
                <div className="w-12 h-12 rounded-full bg-accent/10 flex items-center justify-center">
                  <span className="text-accent text-lg font-bold">{data.metrics.open_count ?? 0}</span>
                </div>
                <div>
                  <p className="text-[13px] text-text-tertiary">Opens</p>
                  <p className="text-[15px] font-medium text-text-primary">{data.metrics.is_opened ? "Opened" : "Not opened"}</p>
                </div>
              </div>
              <div className="flex items-center gap-3">
                <div className="w-12 h-12 rounded-full bg-accent/10 flex items-center justify-center">
                  <span className="text-accent text-lg font-bold">{data.metrics.click_count ?? 0}</span>
                </div>
                <div>
                  <p className="text-[13px] text-text-tertiary">Clicks</p>
                  <p className="text-[15px] font-medium text-text-primary">{data.metrics.is_clicked ? "Clicked" : "Not clicked"}</p>
                </div>
              </div>
              {data.metrics.is_complained && (
                <div className="flex items-center gap-3">
                  <div className="w-12 h-12 rounded-full bg-danger/10 flex items-center justify-center">
                    <span className="text-danger text-lg font-bold">!</span>
                  </div>
                  <div>
                    <p className="text-[13px] text-text-tertiary">Complaint</p>
                    <p className="text-[15px] font-medium text-danger">Complained</p>
                  </div>
                </div>
              )}
            </div>
          </div>
        )}

        {data.attachments && data.attachments.length > 0 && (
          <div className="glass p-5">
            <h3 className="text-[15px] font-semibold text-text-primary mb-4">Attachments</h3>
            <div className="flex flex-col gap-2">
              {data.attachments.map((a) => (
                <div key={a.id} className="flex items-center gap-3 glass-sm px-4 py-2.5 rounded-lg">
                  <Paperclip className="h-4 w-4 text-text-tertiary" />
                  <span className="text-[14px] text-text-primary flex-1">{a.filename}</span>
                  <span className="text-[12px] text-text-tertiary">{(a.size / 1024).toFixed(1)} KB</span>
                </div>
              ))}
            </div>
          </div>
        )}



        <div className="glass p-5">
          <Tabs
            tabs={[
              { id: "html", label: "HTML Preview" },
              { id: "text", label: "Plain Text" },
            ]}
            active={activeTab}
            onChange={setActiveTab}
          />
          <div className="mt-4">
            {activeTab === "html" ? (
              <iframe
                srcDoc={data.html_body}
                className="w-full h-[500px] rounded-lg border border-[rgba(0,0,0,0.06)] bg-white"
                title="HTML Preview"
                sandbox=""
              />
            ) : (
              <pre className="input-glass p-4 rounded-lg text-[14px] text-text-primary font-mono whitespace-pre-wrap overflow-x-auto max-h-[500px]">
                {data.text_body || "(no plain text fallback)"}
              </pre>
            )}
          </div>
        </div>
      </div>
    </PageShell>
  );
}
