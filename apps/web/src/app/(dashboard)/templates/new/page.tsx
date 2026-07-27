"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { api } from "@/lib/api";
import { PageShell } from "@/components/layout/PageShell";
import { Button } from "@/components/ui/Button";
import { Input } from "@/components/ui/Input";
import { useToast } from "@/components/ui/Toast";

export default function CreateTemplatePage() {
  const router = useRouter();
  const { toast } = useToast();
  const [name, setName] = useState("");
  const [subject, setSubject] = useState("");
  const [htmlBody, setHtmlBody] = useState("");
  const [textBody, setTextBody] = useState("");
  const [saving, setSaving] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!name.trim()) return;
    setSaving(true);
    try {
      const template: any = await api.post("/templates", { name, subject, htmlBody, textBody });
      toast({ type: "success", title: "Template created" });
      router.push(`/templates/${template.id}`);
    } catch (e: any) {
      toast({ type: "error", title: "Failed to create template", message: e.message });
    } finally {
      setSaving(false);
    }
  };

  return (
    <PageShell title="Create Template">
      <form onSubmit={handleSubmit} className="glass max-w-3xl p-6 flex flex-col gap-5">
        <Input label="Name" placeholder="My Template" value={name} onChange={(e) => setName(e.target.value)} />
        <Input label="Subject" placeholder="Hello {{name}}!" value={subject} onChange={(e) => setSubject(e.target.value)} />

        <div className="flex flex-col gap-1.5">
          <label className="text-[13px] font-medium text-text-secondary">HTML Body</label>
          <textarea
            className="input-glass w-full px-3.5 py-2.5 text-[15px] text-text-primary placeholder:text-text-tertiary font-mono focus:outline-none transition-all duration-200"
            rows={12}
            placeholder="<html><body>Hi {{name}}!</body></html>"
            value={htmlBody}
            onChange={(e) => setHtmlBody(e.target.value)}
          />
        </div>

        <div className="flex flex-col gap-1.5">
          <label className="text-[13px] font-medium text-text-secondary">Text Fallback (optional)</label>
          <textarea
            className="input-glass w-full px-3.5 py-2.5 text-[15px] text-text-primary placeholder:text-text-tertiary font-mono focus:outline-none transition-all duration-200"
            rows={6}
            placeholder="Hi {{name}}! (fallback for plain-text clients)"
            value={textBody}
            onChange={(e) => setTextBody(e.target.value)}
          />
        </div>

        <div className="flex items-center gap-3 pt-2">
          <Button type="submit" loading={saving}>Create Template</Button>
          <Button variant="secondary" type="button" onClick={() => router.back()}>Cancel</Button>
        </div>
      </form>
    </PageShell>
  );
}
