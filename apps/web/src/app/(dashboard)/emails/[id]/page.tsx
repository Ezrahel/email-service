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
import { ArrowLeft, AlertCircle } from "lucide-react";

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
  created_at: string;
  deliveries: Delivery[];
}

export default function EmailDetailPage() {
  const router = useRouter();
  const params = useParams();
  const { toast } = useToast();
  const [data, setData] = useState<EmailData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [activeTab, setActiveTab] = useState("html");

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
      actions={<Button variant="ghost" onClick={() => router.push("/emails")} icon={<ArrowLeft className="h-4 w-4" />}>Back</Button>}
    >
      <div className="flex flex-col gap-5 max-w-4xl">
        <EmailStatusBadge status={data.status} />
        <div className="flex items-center gap-2 text-[14px] text-text-secondary -mt-3">
          <span>{formatDate(data.created_at)}</span>
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

        <DeliveryTimeline deliveries={data.deliveries} status={data.status} />

        {data.deliveries && data.deliveries.length > 0 && (
          <div className="glass p-5">
            <h3 className="text-[15px] font-semibold text-text-primary mb-4">Delivery Details</h3>
            <div className="flex flex-col gap-3">
              {data.deliveries.map((d) => (
                <div key={d.id} className="glass-sm p-4 grid grid-cols-3 gap-4">
                  <div>
                    <p className="text-[13px] text-text-tertiary mb-0.5">Provider</p>
                    <p className="text-[15px] text-text-primary font-medium">{d.provider}</p>
                  </div>
                  <div>
                    <p className="text-[13px] text-text-tertiary mb-0.5">Attempts</p>
                    <p className="text-[15px] text-text-primary">{d.attempts}</p>
                  </div>
                  <div>
                    <p className="text-[13px] text-text-tertiary mb-0.5">Response Code</p>
                    <p className="text-[15px] text-text-primary font-mono">{d.response_code || "-"}</p>
                  </div>
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
