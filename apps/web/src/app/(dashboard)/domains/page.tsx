"use client";

import { useState, useEffect, useCallback } from "react";
import { clsx } from "clsx";
import { api } from "@/lib/api";
import { PageShell } from "@/components/layout/PageShell";
import { Button } from "@/components/ui/Button";
import { Badge } from "@/components/ui/Badge";
import { Skeleton } from "@/components/ui/Skeleton";
import { Modal } from "@/components/ui/Modal";
import { Input } from "@/components/ui/Input";
import { CopyButton } from "@/components/ui/CopyButton";
import { EmptyState } from "@/components/ui/EmptyState";
import { Dialog } from "@/components/ui/Dialog";
import { useToast } from "@/components/ui/Toast";
import { Plus, Globe, ChevronDown, ChevronUp, Shield, CheckCircle, XCircle, RotateCw, Trash2 } from "lucide-react";

interface Domain {
  id: string;
  domain: string;
  status: string;
  dkim_verified: boolean;
  spf_verified: boolean;
  dmarc_verified: boolean;
  dkim_selector: string;
  created_at: string;
}

interface DnsRecord {
  type: string;
  name: string;
  value: string;
  verified: boolean;
  label: string;
}

function formatDate(dateStr: string) {
  return new Date(dateStr).toLocaleDateString();
}

function DomainCard({ domain, onVerify, onDelete }: { domain: Domain; onVerify: (id: string) => void; onDelete: (domain: Domain) => void }) {
  const [expanded, setExpanded] = useState(false);
  const [verifying, setVerifying] = useState(false);

  const dnsRecords: DnsRecord[] = [
    {
      type: "TXT",
      name: `@`,
      value: `v=spf1 include:resendbyte.co ~all`,
      verified: domain.spf_verified,
      label: "SPF",
    },
    {
      type: "TXT",
      name: `${domain.dkim_selector}._domainkey`,
      value: `v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC...`,
      verified: domain.dkim_verified,
      label: "DKIM",
    },
    {
      type: "TXT",
      name: `_dmarc`,
      value: `v=DMARC1; p=none; rua=mailto:dmarc@${domain.domain}`,
      verified: domain.dmarc_verified,
      label: "DMARC",
    },
  ];

  const handleVerify = async () => {
    setVerifying(true);
    try {
      await api.post(`/domains/${domain.id}/verify`);
      onVerify(domain.id);
    } finally {
      setVerifying(false);
    }
  };

  const allVerified = domain.spf_verified && domain.dkim_verified && domain.dmarc_verified;

  return (
    <div className="glass p-5 animate-fade-in">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3 min-w-0">
          <Globe className="h-5 w-5 text-text-secondary shrink-0" />
          <div className="min-w-0">
            <p className="text-[17px] font-semibold text-text-primary truncate">{domain.domain}</p>
            <p className="text-[13px] text-text-tertiary">Added {formatDate(domain.created_at)}</p>
          </div>
        </div>
        <div className="flex items-center gap-2 shrink-0">
          <Badge variant={allVerified ? "success" : "warning"} dot>
            {allVerified ? "Verified" : "Pending"}
          </Badge>
          <Button size="sm" variant="ghost" onClick={() => setExpanded(!expanded)}>
            {expanded ? <ChevronUp className="h-4 w-4" /> : <ChevronDown className="h-4 w-4" />}
          </Button>
          <Button
            size="sm"
            variant="ghost"
            className="text-text-tertiary hover:text-danger shrink-0"
            onClick={() => onDelete(domain)}
          >
            <Trash2 className="h-4 w-4" />
          </Button>
        </div>
      </div>

      {expanded && (
        <div className="mt-4 pt-4 border-t border-[rgba(0,0,0,0.04)] flex flex-col gap-4">
          {dnsRecords.map((record) => (
            <div key={record.label} className={clsx(
              "glass-sm p-4",
              record.verified ? "border-l-4 border-l-success" : "border-l-4 border-l-warning",
            )}>
              <div className="flex items-center justify-between mb-2">
                <div className="flex items-center gap-2">
                  <Shield className="h-4 w-4 text-text-tertiary" />
                  <span className="text-[14px] font-semibold text-text-primary">{record.label} Record</span>
                  {record.verified ? (
                    <Badge variant="success" dot>Verified</Badge>
                  ) : (
                    <Badge variant="warning" dot>Pending</Badge>
                  )}
                </div>
              </div>
              <div className="grid grid-cols-[auto_1fr] gap-x-3 gap-y-1 text-[13px]">
                <span className="text-text-tertiary">Type:</span>
                <span className="text-text-primary font-mono">{record.type}</span>
                <span className="text-text-tertiary">Name:</span>
                <span className="text-text-primary font-mono break-all">{record.name}</span>
                <span className="text-text-tertiary">Value:</span>
                <span className="text-text-primary font-mono text-[12px] break-all flex items-start gap-1">
                  {record.value}
                  <CopyButton value={record.value} />
                </span>
              </div>
            </div>
          ))}
          <div className="flex justify-end">
            <Button size="sm" variant="secondary" onClick={handleVerify} loading={verifying} icon={<RotateCw className="h-4 w-4" />}>
              Verify DNS
            </Button>
          </div>
        </div>
      )}
    </div>
  );
}

export default function DomainsPage() {
  const { toast } = useToast();
  const [data, setData] = useState<Domain[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [addOpen, setAddOpen] = useState(false);
  const [domainName, setDomainName] = useState("");
  const [adding, setAdding] = useState(false);
  const [deleteTarget, setDeleteTarget] = useState<Domain | null>(null);
  const [deleting, setDeleting] = useState(false);

  const fetchDomains = useCallback(async () => {
    setLoading(true);
    setError("");
    try {
      const res: any = await api.get("/domains");
      setData(res || []);
    } catch (e: any) {
      setError(e.message || "Failed to load domains");
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => { fetchDomains(); }, [fetchDomains]);

  const handleAdd = async () => {
    if (!domainName.trim()) return;
    setAdding(true);
    try {
      await api.post("/domains", { domain: domainName.trim() });
      toast({ type: "success", title: "Domain added" });
      setAddOpen(false);
      setDomainName("");
      fetchDomains();
    } catch (e: any) {
      toast({ type: "error", title: "Failed to add domain", message: e.message });
    } finally {
      setAdding(false);
    }
  };

  const handleDelete = async () => {
    if (!deleteTarget) return;
    setDeleting(true);
    try {
      await api.delete(`/domains/${deleteTarget.id}`);
      toast({ type: "success", title: "Domain deleted" });
      setDeleteTarget(null);
      fetchDomains();
    } catch (e: any) {
      toast({ type: "error", title: "Failed to delete domain", message: e.message });
    } finally {
      setDeleting(false);
    }
  };

  return (
    <PageShell
      title="Domains"
      actions={
        <Button onClick={() => setAddOpen(true)} icon={<Plus className="h-4 w-4" />}>
          Add Domain
        </Button>
      }
    >
      {error && (
        <div className="glass-sm p-4 mb-6 text-danger flex items-center justify-between">
          <span>{error}</span>
          <Button variant="ghost" size="sm" onClick={fetchDomains}>Retry</Button>
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
                  <Skeleton className="h-4 w-24" />
                </div>
                <Skeleton className="h-6 w-20 rounded-full" />
              </div>
            </div>
          ))}
        </div>
      ) : data.length === 0 ? (
        <EmptyState
          icon={<Globe className="h-10 w-10" />}
          title="No domains configured"
          description="Add a domain to start sending emails from your own address."
          action={{ label: "Add Domain", onClick: () => setAddOpen(true) }}
        />
      ) : (
        <div className="flex flex-col gap-4">
          {data.map((domain) => (
            <DomainCard key={domain.id} domain={domain} onVerify={fetchDomains} onDelete={setDeleteTarget} />
          ))}
        </div>
      )}

      <Modal open={addOpen} onClose={() => setAddOpen(false)} title="Add Domain">
        <div className="flex flex-col gap-4">
          <Input
            label="Domain Name"
            placeholder="example.com"
            value={domainName}
            onChange={(e) => setDomainName(e.target.value)}
          />
          <div className="flex items-center justify-end gap-3">
            <Button variant="secondary" onClick={() => setAddOpen(false)}>Cancel</Button>
            <Button onClick={handleAdd} loading={adding}>Add Domain</Button>
          </div>
        </div>
      </Modal>

      <Dialog
        open={!!deleteTarget}
        onClose={() => setDeleteTarget(null)}
        title="Delete Domain"
        message={`Are you sure you want to delete "${deleteTarget?.domain || ""}"? This domain will be permanently deleted and any emails sent from it will be affected.`}
        confirmLabel="Delete"
        variant="danger"
        loading={deleting}
        onConfirm={handleDelete}
      />
    </PageShell>
  );
}
