"use client";

import { useState, useEffect, useMemo } from "react";
import { api } from "@/lib/api";
import { Button } from "@/components/ui/Button";
import { Input } from "@/components/ui/Input";
import { Modal } from "@/components/ui/Modal";
import { useToast } from "@/components/ui/Toast";
import { Send } from "lucide-react";

function extractVariables(text: string): string[] {
  const matches = text.match(/\{\{(\w+)\}\}/g);
  if (!matches) return [];
  return [...new Set(matches.map((m) => m.slice(2, -2)))];
}

interface SendTemplateModalProps {
  open: boolean;
  onClose: () => void;
  templateId: string;
  templateContent?: string;
  onSent?: (emailId: string) => void;
}

export function SendTemplateModal({ open, onClose, templateId, templateContent, onSent }: SendTemplateModalProps) {
  const { toast } = useToast();
  const [sendTo, setSendTo] = useState("");
  const [variables, setVariables] = useState<Record<string, string>>({});
  const [sending, setSending] = useState(false);

  const variableNames = useMemo(() => {
    if (!templateContent) return [];
    return extractVariables(templateContent);
  }, [templateContent]);

  useEffect(() => {
    if (open) {
      const defaults: Record<string, string> = {};
      variableNames.forEach((v) => { defaults[v] = ""; });
      setVariables(defaults);
      setSendTo("");
    }
  }, [open, variableNames]);

  const handleSend = async () => {
    if (!sendTo.trim()) return;
    setSending(true);
    try {
      const email: any = await api.post(`/templates/${templateId}/send`, {
        to: sendTo,
        variables,
      });
      toast({ type: "success", title: "Email sent from template" });
      onClose();
      onSent?.(email.id);
    } catch (e: any) {
      toast({ type: "error", title: "Failed to send", message: e.message });
    } finally {
      setSending(false);
    }
  };

  return (
    <Modal open={open} onClose={onClose} title="Send from Template">
      <div className="flex flex-col gap-4">
        <Input label="To" placeholder="recipient@example.com" value={sendTo} onChange={(e) => setSendTo(e.target.value)} />
        {variableNames.map((name) => (
          <Input
            key={name}
            label={`{{${name}}}`}
            placeholder={`Value for ${name}`}
            value={variables[name] || ""}
            onChange={(e) => setVariables((prev) => ({ ...prev, [name]: e.target.value }))}
          />
        ))}
        <div className="flex items-center justify-end gap-3 pt-2">
          <Button variant="secondary" onClick={onClose}>Cancel</Button>
          <Button onClick={handleSend} loading={sending} icon={<Send className="h-4 w-4" />}>Send</Button>
        </div>
      </div>
    </Modal>
  );
}
