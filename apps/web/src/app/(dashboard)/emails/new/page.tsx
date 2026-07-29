"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { api } from "@/lib/api";
import { PageShell } from "@/components/layout/PageShell";
import { Button } from "@/components/ui/Button";
import { Input } from "@/components/ui/Input";
import { Badge } from "@/components/ui/Badge";
import { useToast } from "@/components/ui/Toast";
import { ArrowLeft, Send, MailCheck, Shield, Paperclip, Clock, X } from "lucide-react";

export default function ComposeEmailPage() {
  const router = useRouter();
  const { toast } = useToast();
  const [from, setFrom] = useState("");
  const [to, setTo] = useState("");
  const [subject, setSubject] = useState("");
  const [replyTo, setReplyTo] = useState("");
  const [tags, setTags] = useState("");
  const [html, setHtml] = useState("");
  const [text, setText] = useState("");
  const [scheduledAt, setScheduledAt] = useState("");
  const [attachmentIds, setAttachmentIds] = useState<string[]>([]);
  const [attaching, setAttaching] = useState(false);
  const [sending, setSending] = useState(false);
  const [validating, setValidating] = useState(false);

  const buildPayload = () => ({
    from,
    to: to.split(",").map((s) => s.trim()).filter(Boolean),
    subject,
    html,
    text: text || undefined,
    replyTo: replyTo || undefined,
    tags: tags
      ? tags.split(",").map((s) => s.trim()).filter(Boolean)
      : undefined,
    idempotencyKey: crypto.randomUUID(),
    scheduledAt: scheduledAt || undefined,
    attachmentIds: attachmentIds.length > 0 ? attachmentIds : undefined,
  });

  const handleAttach = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    setAttaching(true);
    try {
      const formData = new FormData();
      formData.append("file", file);
      const res: any = await api.post("/attachments", formData);
      setAttachmentIds((prev) => [...prev, res.id]);
    } catch (err: any) {
      toast({ type: "error", title: "Upload failed", message: err.message });
    } finally {
      setAttaching(false);
    }
  };

  const handleSend = async () => {
    setSending(true);
    try {
      const email: any = await api.post("/emails", buildPayload());
      toast({ type: "success", title: "Email sent successfully" });
      router.push(`/emails/${email.id}`);
    } catch (e: any) {
      toast({ type: "error", title: "Failed to send", message: e.message });
    } finally {
      setSending(false);
    }
  };

  const handleSendBatch = async () => {
    setSending(true);
    try {
      const payload = buildPayload();
      await api.post("/emails/batch", payload);
      toast({ type: "success", title: "Batch emails queued" });
      router.push("/emails");
    } catch (e: any) {
      toast({ type: "error", title: "Failed to send batch", message: e.message });
    } finally {
      setSending(false);
    }
  };

  const handleValidate = async () => {
    setValidating(true);
    try {
      await api.post("/emails/validate", buildPayload());
      toast({ type: "success", title: "Validation passed" });
    } catch (e: any) {
      toast({ type: "error", title: "Validation failed", message: e.message });
    } finally {
      setValidating(false);
    }
  };

  return (
    <PageShell
      title="Compose Email"
      actions={
        <Button variant="ghost" onClick={() => router.back()} icon={<ArrowLeft className="h-4 w-4" />}>
          Back
        </Button>
      }
    >
      <div className="glass max-w-3xl p-6 flex flex-col gap-5">
        <Input label="From" placeholder="sender@example.com" value={from} onChange={(e) => setFrom(e.target.value)} />
        <Input label="To" placeholder="recipient@example.com, another@example.com" value={to} onChange={(e) => setTo(e.target.value)} />
        <Input label="Subject" placeholder="Email subject" value={subject} onChange={(e) => setSubject(e.target.value)} />
        <Input label="Reply-To (optional)" placeholder="reply@example.com" value={replyTo} onChange={(e) => setReplyTo(e.target.value)} />
        <Input label="Tags (optional)" placeholder="tag1, tag2" value={tags} onChange={(e) => setTags(e.target.value)} />

        <div className="flex flex-col gap-1.5">
          <label className="text-[13px] font-medium text-text-secondary">HTML Body</label>
          <textarea
            className="input-glass w-full px-3.5 py-2.5 text-[15px] text-text-primary placeholder:text-text-tertiary font-mono focus:outline-none transition-all duration-200"
            rows={12}
            placeholder="<html><body>Hello!</body></html>"
            value={html}
            onChange={(e) => setHtml(e.target.value)}
          />
        </div>

        <div className="flex flex-col gap-1.5">
          <label className="text-[13px] font-medium text-text-secondary">Plain Text (optional)</label>
          <textarea
            className="input-glass w-full px-3.5 py-2.5 text-[15px] text-text-primary placeholder:text-text-tertiary font-mono focus:outline-none transition-all duration-200"
            rows={6}
            placeholder="Hello! (fallback for plain-text clients)"
            value={text}
            onChange={(e) => setText(e.target.value)}
          />
        </div>

        <div className="grid grid-cols-2 gap-4">
          <Input
            label="Schedule Send (optional)"
            type="datetime-local"
            value={scheduledAt}
            onChange={(e) => setScheduledAt(e.target.value)}
          />
          <div className="flex flex-col gap-1.5">
            <label className="text-[13px] font-medium text-text-secondary">Attachments</label>
            <div className="flex items-center gap-2">
              <Button
                variant="secondary"
                size="sm"
                loading={attaching}
                icon={<Paperclip className="h-4 w-4" />}
                onClick={() => document.getElementById("file-upload")?.click()}
              >
                Upload
              </Button>
              <input
                id="file-upload"
                type="file"
                className="hidden"
                onChange={handleAttach}
              />
            </div>
            {attachmentIds.length > 0 && (
              <div className="flex flex-wrap gap-2 mt-1">
                {attachmentIds.map((id) => (
                  <Badge key={id} variant="info" className="flex items-center gap-1">
                    Attached
                    <button
                      onClick={() => setAttachmentIds((prev) => prev.filter((x) => x !== id))}
                      className="hover:text-danger transition-colors"
                    >
                      <X className="h-3 w-3" />
                    </button>
                  </Badge>
                ))}
              </div>
            )}
          </div>
        </div>

        <div className="flex items-center gap-3 pt-2">
          <Button onClick={handleSend} loading={sending} icon={<Send className="h-4 w-4" />}>
            Send
          </Button>
          <Button variant="secondary" onClick={handleSendBatch} loading={sending} icon={<MailCheck className="h-4 w-4" />}>
            Send Batch
          </Button>
          <Button variant="ghost" onClick={handleValidate} loading={validating} icon={<Shield className="h-4 w-4" />}>
            Validate
          </Button>
        </div>
      </div>
    </PageShell>
  );
}
