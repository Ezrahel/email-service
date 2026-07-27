"use client";

import { useState, useEffect, useCallback } from "react";
import { clsx } from "clsx";
import { api } from "@/lib/api";
import { SCOPES, SCOPE_IDS } from "@/lib/constants";
import { PageShell } from "@/components/layout/PageShell";
import { Button } from "@/components/ui/Button";
import { Badge } from "@/components/ui/Badge";
import { Skeleton } from "@/components/ui/Skeleton";
import { Modal } from "@/components/ui/Modal";
import { Dialog } from "@/components/ui/Dialog";
import { Input } from "@/components/ui/Input";
import { CopyButton } from "@/components/ui/CopyButton";
import { useToast } from "@/components/ui/Toast";
import { Plus, Key, Trash2, AlertTriangle } from "lucide-react";

function formatDate(dateStr: string | null) {
  if (!dateStr) return "-";
  return new Date(dateStr).toLocaleDateString();
}

interface ApiKey {
  id: string;
  name: string;
  key_prefix: string;
  key_last_chars: string;
  scopes: string[];
  status: string;
  expires_at: string | null;
  last_used_at: string | null;
  created_at: string;
}

export default function ApiKeysPage() {
  const { toast } = useToast();
  const [data, setData] = useState<ApiKey[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [createOpen, setCreateOpen] = useState(false);
  const [step, setStep] = useState(1);
  const [keyName, setKeyName] = useState("");
  const [keyScopes, setKeyScopes] = useState<string[]>([...SCOPE_IDS]);
  const [keyExpiry, setKeyExpiry] = useState("");
  const [creating, setCreating] = useState(false);
  const [createdKey, setCreatedKey] = useState<string | null>(null);
  const [revokeTarget, setRevokeTarget] = useState<ApiKey | null>(null);
  const [revoking, setRevoking] = useState(false);

  const fetchKeys = useCallback(async () => {
    setLoading(true);
    setError("");
    try {
      const res: any = await api.get("/api-keys");
      setData(res || []);
    } catch (e: any) {
      setError(e.message || "Failed to load API keys");
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => { fetchKeys(); }, [fetchKeys]);

  const toggleScope = (scopeId: string) => {
    setKeyScopes((prev) =>
      prev.includes(scopeId) ? prev.filter((s) => s !== scopeId) : [...prev, scopeId],
    );
  };

  const openCreate = () => {
    setStep(1);
    setKeyName("");
    setKeyScopes([...SCOPE_IDS]);
    setKeyExpiry("");
    setCreatedKey(null);
    setCreateOpen(true);
  };

  const handleCreateStep1 = () => {
    if (!keyName.trim()) return;
    setStep(2);
  };

  const handleCreateFinal = async () => {
    setCreating(true);
    try {
      const res: any = await api.post("/api-keys", {
        name: keyName.trim(),
        scopes: keyScopes,
        expiresAt: keyExpiry || undefined,
      });
      setCreatedKey(res.key || res.api_key || (res as any).key);
      toast({ type: "success", title: "API key created" });
      fetchKeys();
    } catch (e: any) {
      toast({ type: "error", title: "Failed to create API key", message: e.message });
    } finally {
      setCreating(false);
    }
  };

  const handleRevoke = async () => {
    if (!revokeTarget) return;
    setRevoking(true);
    try {
      await api.delete(`/api-keys/${revokeTarget.id}`);
      toast({ type: "success", title: "API key revoked" });
      setRevokeTarget(null);
      fetchKeys();
    } catch (e: any) {
      toast({ type: "error", title: "Failed to revoke", message: e.message });
    } finally {
      setRevoking(false);
    }
  };

  const resetCreate = () => {
    setCreateOpen(false);
    setStep(1);
    setCreatedKey(null);
  };

  const renderCard = (key: ApiKey) => (
    <div key={key.id} className="glass p-5 animate-fade-in">
      <div className="flex items-start justify-between">
        <div className="flex items-center gap-3 min-w-0">
          <Key className="h-5 w-5 text-text-secondary shrink-0 mt-0.5" />
          <div className="min-w-0">
            <p className="text-[15px] font-medium text-text-primary">{key.name}</p>
            <p className="text-[14px] font-mono text-text-tertiary mt-0.5">
              {key.key_prefix}****{key.key_last_chars}
            </p>
            <div className="flex items-center gap-2 mt-1.5 flex-wrap">
              <Badge variant={key.status === "active" ? "success" : "danger"} dot>
                {key.status}
              </Badge>
              {key.scopes.map((scope) => (
                <Badge key={scope} variant="info">{scope}</Badge>
              ))}
            </div>
            <div className="flex items-center gap-4 mt-1 text-[13px] text-text-tertiary">
              <span>Created {formatDate(key.created_at)}</span>
              {key.last_used_at && <span>Last used {formatDate(key.last_used_at)}</span>}
              {key.expires_at && <span>Expires {formatDate(key.expires_at)}</span>}
            </div>
          </div>
        </div>
        <Button
          size="sm"
          variant="ghost"
          className="text-text-tertiary hover:text-danger shrink-0"
          onClick={() => setRevokeTarget(key)}
        >
          <Trash2 className="h-4 w-4" />
        </Button>
      </div>
    </div>
  );

  return (
    <PageShell
      title="API Keys"
      actions={
        <Button onClick={openCreate} icon={<Plus className="h-4 w-4" />}>
          Create Key
        </Button>
      }
    >
      {error && (
        <div className="glass-sm p-4 mb-6 text-danger flex items-center justify-between">
          <span>{error}</span>
          <Button variant="ghost" size="sm" onClick={fetchKeys}>Retry</Button>
        </div>
      )}

      {loading ? (
        <div className="flex flex-col gap-4">
          {Array.from({ length: 3 }).map((_, i) => (
            <div key={i} className="glass p-5">
              <div className="flex items-center gap-3">
                <Skeleton className="h-5 w-5 rounded" />
                <div className="flex-1">
                  <Skeleton className="h-5 w-40 mb-1" />
                  <Skeleton className="h-4 w-32 mb-1" />
                  <Skeleton className="h-4 w-56" />
                </div>
              </div>
            </div>
          ))}
        </div>
      ) : data.length === 0 ? (
        <div className="glass p-8 flex flex-col items-center text-center max-w-sm mx-auto">
          <Key className="h-10 w-10 text-text-tertiary mb-3" />
          <h3 className="text-[17px] font-semibold text-text-primary mb-1">No API keys</h3>
          <p className="text-[14px] text-text-secondary leading-relaxed mb-5">
            Create an API key to integrate with external services.
          </p>
          <Button variant="secondary" onClick={openCreate} icon={<Plus className="h-4 w-4" />}>
            Create your first key
          </Button>
        </div>
      ) : (
        <div className="flex flex-col gap-4">
          {data.map(renderCard)}
        </div>
      )}

      <Modal
        open={createOpen}
        onClose={resetCreate}
        title={step === 1 ? "Create API Key" : "API Key Created"}
        className={step === 2 ? "max-w-md" : undefined}
      >
        {step === 1 ? (
          <div className="flex flex-col gap-4">
            <Input label="Key Name" placeholder="Production API Key" value={keyName} onChange={(e) => setKeyName(e.target.value)} />
            <div>
              <p className="text-[13px] font-medium text-text-secondary mb-2">Scopes</p>
              <div className="flex flex-wrap gap-2">
                {SCOPES.map((scope) => (
                  <button
                    key={scope.id}
                    type="button"
                    onClick={() => toggleScope(scope.id)}
                    className={clsx(
                      "px-3 py-1.5 rounded-lg text-[13px] font-medium transition-colors border",
                      keyScopes.includes(scope.id)
                        ? "bg-accent text-white border-accent"
                        : "bg-transparent text-text-secondary border-[rgba(0,0,0,0.1)] hover:border-accent hover:text-accent",
                    )}
                  >
                    {scope.label}
                  </button>
                ))}
              </div>
            </div>
            <Input label="Expires At (optional)" type="date" value={keyExpiry} onChange={(e) => setKeyExpiry(e.target.value)} />
            <div className="flex items-center justify-end gap-3 pt-2">
              <Button variant="secondary" onClick={resetCreate}>Cancel</Button>
              <Button onClick={handleCreateStep1}>Next</Button>
            </div>
          </div>
        ) : (
          <div className="flex flex-col gap-4">
            <div className="glass-sm p-4 flex items-start gap-3 bg-warning/10 border border-warning/20 rounded-lg">
              <AlertTriangle className="h-5 w-5 text-warning shrink-0 mt-0.5" />
              <div>
                <p className="text-[14px] font-medium text-warning">Copy this key now</p>
                <p className="text-[13px] text-text-secondary mt-0.5">You won&apos;t be able to see it again after closing this dialog.</p>
              </div>
            </div>
            <div className="flex items-center gap-2 bg-[rgba(0,0,0,0.03)] p-3 rounded-lg">
              <code className="flex-1 text-[14px] font-mono text-text-primary break-all">
                {createdKey}
              </code>
              <CopyButton value={createdKey || ""} />
            </div>
            <div className="flex justify-end pt-2">
              <Button onClick={resetCreate}>Done</Button>
            </div>
          </div>
        )}
      </Modal>

      <Dialog
        open={!!revokeTarget}
        onClose={() => setRevokeTarget(null)}
        title="Revoke API Key"
        message={`Are you sure you want to revoke "${revokeTarget?.name || ""}"? Any services using this key will immediately lose access.`}
        confirmLabel="Revoke"
        variant="danger"
        loading={revoking}
        onConfirm={handleRevoke}
      />
    </PageShell>
  );
}
