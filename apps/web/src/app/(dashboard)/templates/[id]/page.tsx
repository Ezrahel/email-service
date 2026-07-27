"use client";

import { useState, useEffect, useMemo } from "react";
import { useRouter, useParams } from "next/navigation";
import { api } from "@/lib/api";
import { PageShell } from "@/components/layout/PageShell";
import { Button } from "@/components/ui/Button";
import { Badge } from "@/components/ui/Badge";
import { Skeleton } from "@/components/ui/Skeleton";
import { useToast } from "@/components/ui/Toast";
import { SendTemplateModal } from "@/components/templates/SendTemplateModal";
import { ArrowLeft, Send } from "lucide-react";

function extractVariables(text: string): string[] {
  const matches = text.match(/\{\{(\w+)\}\}/g);
  if (!matches) return [];
  return [...new Set(matches.map((m) => m.slice(2, -2)))];
}

export default function TemplateDetailPage() {
  const router = useRouter();
  const params = useParams();
  const { toast } = useToast();
  const [template, setTemplate] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [sendOpen, setSendOpen] = useState(false);

  const fetchTemplate = async () => {
    setLoading(true);
    setError("");
    try {
      const res: any = await api.get(`/templates/${params.id}`);
      setTemplate(res);
    } catch (e: any) {
      setError(e.message || "Template not found");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (params.id) fetchTemplate();
  }, [params.id]);

  const variableNames = useMemo(() => {
    if (!template) return [];
    const fromSubject = extractVariables(template.subject || "");
    const fromHtml = extractVariables(template.htmlBody || "");
    const fromText = extractVariables(template.textBody || "");
    return [...new Set([...fromSubject, ...fromHtml, ...fromText])];
  }, [template]);

  const templateContent = useMemo(() => {
    if (!template) return "";
    return [template.subject, template.htmlBody, template.textBody].filter(Boolean).join(" ");
  }, [template]);

  if (loading) {
    return (
      <PageShell title="Template" actions={<Button variant="ghost" onClick={() => router.push("/templates")} icon={<ArrowLeft className="h-4 w-4" />}>Back</Button>}>
        <div className="flex flex-col gap-5">
          <Skeleton className="h-8 w-48" />
          <Skeleton className="h-24 w-full" />
          <Skeleton className="h-8 w-32" />
        </div>
      </PageShell>
    );
  }

  if (error) {
    return (
      <PageShell title="Template" actions={<Button variant="ghost" onClick={() => router.push("/templates")} icon={<ArrowLeft className="h-4 w-4" />}>Back</Button>}>
        <div className="glass p-8 flex flex-col items-center text-center max-w-md mx-auto">
          <p className="text-[15px] text-danger mb-4">{error}</p>
          <Button variant="secondary" onClick={() => router.push("/templates")}>Back to Templates</Button>
        </div>
      </PageShell>
    );
  }

  return (
    <PageShell
      title={template?.name || "Template"}
      actions={
        <div className="flex items-center gap-2">
          <Button variant="ghost" onClick={() => router.push("/templates")} icon={<ArrowLeft className="h-4 w-4" />}>Back</Button>
          <Button onClick={() => setSendOpen(true)} icon={<Send className="h-4 w-4" />}>Send from Template</Button>
        </div>
      }
    >
      <div className="flex flex-col gap-5 max-w-3xl">
        <div className="glass p-5 grid grid-cols-3 gap-4">
          <div>
            <p className="text-[13px] text-text-tertiary mb-0.5">Name</p>
            <p className="text-[15px] text-text-primary font-medium">{template?.name}</p>
          </div>
          <div>
            <p className="text-[13px] text-text-tertiary mb-0.5">Slug</p>
            <p className="text-[15px] text-text-primary font-mono">{template?.slug}</p>
          </div>
          <div>
            <p className="text-[13px] text-text-tertiary mb-0.5">Created</p>
            <p className="text-[15px] text-text-primary">{template?.created_at ? new Date(template.created_at).toLocaleDateString() : "-"}</p>
          </div>
        </div>

        {variableNames.length > 0 && (
          <div className="glass p-5">
            <p className="text-[13px] text-text-tertiary mb-2">Template Variables</p>
            <div className="flex flex-wrap gap-2">
              {variableNames.map((v) => (
                <Badge key={v} variant="info">{`{{${v}}}`}</Badge>
              ))}
            </div>
          </div>
        )}
      </div>

      <SendTemplateModal
        open={sendOpen}
        onClose={() => setSendOpen(false)}
        templateId={params.id as string}
        templateContent={templateContent}
        onSent={(emailId) => router.push(`/emails/${emailId}`)}
      />
    </PageShell>
  );
}
