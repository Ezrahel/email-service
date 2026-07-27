"use client";

import { useState, useEffect, useCallback } from "react";
import { useRouter } from "next/navigation";
import { api } from "@/lib/api";
import { PER_PAGE_DEFAULT } from "@/lib/constants";
import { PageShell } from "@/components/layout/PageShell";
import { Button } from "@/components/ui/Button";
import { Skeleton } from "@/components/ui/Skeleton";
import { Pagination } from "@/components/ui/Pagination";
import { EmptyState } from "@/components/ui/EmptyState";
import { Plus, FileText } from "lucide-react";

function formatDate(dateStr: string) {
  return new Date(dateStr).toLocaleDateString();
}

export default function TemplatesPage() {
  const router = useRouter();
  const [data, setData] = useState<any[]>([]);
  const [meta, setMeta] = useState({ page: 1, perPage: PER_PAGE_DEFAULT, total: 0, pages: 0 });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  const fetchTemplates = useCallback(async (page: number) => {
    setLoading(true);
    setError("");
    try {
      const params = new URLSearchParams({ page: String(page), perPage: String(PER_PAGE_DEFAULT) });
      const res: any = await api.get(`/templates?${params}`);
      setData(res.data || []);
      setMeta(res.meta || { page, perPage: PER_PAGE_DEFAULT, total: 0, pages: 0 });
    } catch (e: any) {
      setError(e.message || "Failed to load templates");
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => { fetchTemplates(1); }, [fetchTemplates]);

  return (
    <PageShell
      title="Templates"
      actions={
        <Button onClick={() => router.push("/templates/new")} icon={<Plus className="h-4 w-4" />}>
          Create
        </Button>
      }
    >
      {error && (
        <div className="glass-sm p-4 mb-6 text-danger flex items-center justify-between">
          <span>{error}</span>
          <Button variant="ghost" size="sm" onClick={() => fetchTemplates(meta.page)}>Retry</Button>
        </div>
      )}

      {loading ? (
        <div className="glass rounded-[16px] overflow-hidden">
          {Array.from({ length: 5 }).map((_, i) => (
            <div key={i} className="flex items-center gap-4 px-5 py-4 border-b border-[rgba(0,0,0,0.04)]">
              <Skeleton className="h-4 w-48" />
              <Skeleton className="h-4 w-32" />
              <Skeleton className="h-4 w-24 ml-auto" />
            </div>
          ))}
        </div>
      ) : data.length === 0 ? (
        <EmptyState
          icon={<FileText className="h-10 w-10" />}
          title="No templates yet"
          description="Create your first email template to reuse across campaigns."
          action={{ label: "Create Template", onClick: () => router.push("/templates/new") }}
        />
      ) : (
        <>
          <div className="glass rounded-[16px] overflow-hidden animate-fade-in">
            <div className="grid grid-cols-[1fr_1fr_auto] gap-4 px-5 py-3 text-[13px] font-medium text-text-secondary border-b border-[rgba(0,0,0,0.04)]">
              <span>Name</span>
              <span>Slug</span>
              <span>Created</span>
            </div>
            {data.map((template: any) => (
              <div
                key={template.id}
                className="grid grid-cols-[1fr_1fr_auto] gap-4 px-5 py-3.5 border-b border-[rgba(0,0,0,0.04)] last:border-0 hover:bg-accent-glass cursor-pointer transition-colors items-center text-[15px]"
                onClick={() => router.push(`/templates/${template.id}`)}
              >
                <span className="text-text-primary font-medium">{template.name}</span>
                <span className="text-text-secondary font-mono text-[14px]">{template.slug}</span>
                <span className="text-text-tertiary text-[13px]">{formatDate(template.created_at)}</span>
              </div>
            ))}
          </div>
          {meta.pages > 1 && (
            <Pagination page={meta.page} perPage={meta.perPage} total={meta.total} onChange={(p) => fetchTemplates(p)} />
          )}
        </>
      )}
    </PageShell>
  );
}
