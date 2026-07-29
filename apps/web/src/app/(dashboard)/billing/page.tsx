"use client";

import { useState, useEffect, useCallback } from "react";
import { api } from "@/lib/api";
import { PageShell } from "@/components/layout/PageShell";
import { Button } from "@/components/ui/Button";
import { Badge } from "@/components/ui/Badge";
import { Skeleton } from "@/components/ui/Skeleton";
import { Modal } from "@/components/ui/Modal";
import { useToast } from "@/components/ui/Toast";
import { CreditCard, AlertTriangle } from "lucide-react";

interface Plan {
  id: string;
  name: string;
  slug: string;
  description: string | null;
  monthly_email_limit: number;
  price_cents: number;
  overage_rate_cents: number;
  features: Record<string, unknown>;
  sort_order: number;
}

interface SubscriptionInfo {
  id: string;
  planId: string;
  planName: string;
  planSlug: string;
  status: string;
  periodStart: string;
  periodEnd: string;
  cancelAtPeriodEnd: boolean;
  overageBalanceCents: number;
}

interface UsageInfo {
  sentThisMonth: number;
  limit: number;
  monthStart: string;
  overageEnabled: boolean;
  planSlug: string;
  overageBalanceCents: number;
}

interface Invoice {
  id: string;
  amount_cents: number;
  currency: string;
  status: string;
  description: string | null;
  period_start: string | null;
  period_end: string | null;
  paid_at: string | null;
  created_at: string;
}

export default function BillingPage() {
  const { toast } = useToast();
  const [plans, setPlans] = useState<Plan[]>([]);
  const [subscription, setSubscription] = useState<SubscriptionInfo | null>(null);
  const [usage, setUsage] = useState<UsageInfo | null>(null);
  const [invoices, setInvoices] = useState<Invoice[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [changePlanOpen, setChangePlanOpen] = useState(false);
  const [invoiceLoading, setInvoiceLoading] = useState(false);

  const fetchData = useCallback(async () => {
    try {
      const [plansData, subData, invData] = await Promise.all([
        api.get<Plan[]>("/billing/plans"),
        api.get<{ subscription: SubscriptionInfo | null; usage: UsageInfo }>("/billing/subscription"),
        api.get<Invoice[]>("/billing/invoices"),
      ]);
      setPlans(plansData);
      setSubscription(subData.subscription);
      setUsage(subData.usage);
      setInvoices(invData);
    } catch (err: any) {
      setError(err.message || "Failed to load billing data");
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => { fetchData(); }, [fetchData]);

  const handleChangePlan = async (planSlug: string) => {
    try {
      await api.post("/billing/subscription/change", { planSlug });
      toast({ type: "success", title: "Plan changed" });
      setChangePlanOpen(false);
      fetchData();
    } catch (err: any) {
      toast({ type: "error", title: err.message || "Failed to change plan" });
    }
  };

  const handleToggleOverage = async (enabled: boolean) => {
    try {
      await api.post("/billing/overage", { enabled });
      toast({ type: "success", title: enabled ? "Overage enabled" : "Overage disabled" });
      fetchData();
    } catch (err: any) {
      toast({ type: "error", title: err.message || "Failed to update overage" });
    }
  };

  const handleGenerateInvoice = async () => {
    setInvoiceLoading(true);
    try {
      const result = await api.post<{ id: string; amountCents: number }>("/billing/invoices/generate-overage");
      toast({ type: "success", title: `Overage invoice generated: ${result.amountCents} cents` });
      fetchData();
    } catch (err: any) {
      toast({ type: "error", title: err.message || "Failed to generate invoice" });
    } finally {
      setInvoiceLoading(false);
    }
  };

  const handlePayInvoice = async (invoiceId: string) => {
    try {
      const result = await api.post<{ authorizationUrl: string; reference: string }>(`/billing/invoices/${invoiceId}/pay`);
      window.open(result.authorizationUrl, "_blank");
    } catch (err: any) {
      toast({ type: "error", title: err.message || "Failed to initialize payment" });
    }
  };

  if (loading) {
    return (
      <PageShell title="Billing">
        <div className="space-y-4">
          <Skeleton className="h-32" />
          <Skeleton className="h-48" />
        </div>
      </PageShell>
    );
  }

  if (error) {
    return (
      <PageShell title="Billing">
        <div className="bg-red-50 border border-red-200 rounded-lg p-4 text-red-700">{error}</div>
      </PageShell>
    );
  }

  const usagePercent = usage ? Math.min(100, Math.round((usage.sentThisMonth / usage.limit) * 100)) : 0;
  const currentPlan = plans.find(p => p.slug === (usage?.planSlug || "free"));

  return (
    <PageShell title="Billing">
      <div className="space-y-6 max-w-3xl">
        {subscription?.status === "past_due" && (
          <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-4 text-yellow-800 flex items-center gap-2">
            <AlertTriangle className="w-5 h-5" />
            <span>Your account is past due. Please pay outstanding invoices to avoid suspension.</span>
          </div>
        )}

        <div className="bg-white border rounded-lg p-6">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-lg font-semibold flex items-center gap-2">
              <CreditCard className="w-5 h-5" />
              Current Plan
            </h2>
            <Button variant="secondary" size="sm" onClick={() => setChangePlanOpen(true)}>Change Plan</Button>
          </div>
          <div className="flex items-center gap-3 mb-4">
            <span className="text-2xl font-bold">{currentPlan?.name || "Free"}</span>
            <Badge variant={subscription?.status === "active" ? "success" : "warning"}>
              {subscription?.status || "active"}
            </Badge>
          </div>
          {currentPlan && (
            <p className="text-sm text-gray-500 mb-4">{currentPlan.description}</p>
          )}
          {usage && (
            <div>
              <div className="flex justify-between text-sm mb-1">
                <span>{usage.sentThisMonth.toLocaleString()} sent this month</span>
                <span>{usage.limit.toLocaleString()} limit</span>
              </div>
              <div className="w-full bg-gray-100 rounded-full h-2.5">
                <div
                  className={`h-2.5 rounded-full transition-all ${usagePercent > 90 ? "bg-red-500" : usagePercent > 75 ? "bg-yellow-500" : "bg-blue-500"}`}
                  style={{ width: `${usagePercent}%` }}
                />
              </div>
              <p className="text-xs text-gray-400 mt-1">{usagePercent}% used</p>
            </div>
          )}
        </div>

        {subscription && (
          <div className="bg-white border rounded-lg p-6">
            <h3 className="font-semibold mb-3">Overage</h3>
            <div className="flex items-center justify-between mb-2">
              <span className="text-sm">Pay-as-you-go overage</span>
              <button
                onClick={() => handleToggleOverage(!usage?.overageEnabled)}
                className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors ${usage?.overageEnabled ? "bg-blue-600" : "bg-gray-300"}`}
              >
                <span className={`inline-block h-4 w-4 transform rounded-full bg-white transition-transform ${usage?.overageEnabled ? "translate-x-6" : "translate-x-1"}`} />
              </button>
            </div>
            {usage?.overageEnabled && (
              <div className="text-sm text-gray-500">
                <p>Overage balance: {subscription.overageBalanceCents} emails (at {currentPlan?.overage_rate_cents || 0}c each)</p>
                {subscription.overageBalanceCents > 0 && (
                  <Button variant="secondary" size="sm" className="mt-2" onClick={handleGenerateInvoice} disabled={invoiceLoading}>
                    Generate Overage Invoice
                  </Button>
                )}
              </div>
            )}
          </div>
        )}

        <div className="bg-white border rounded-lg p-6">
          <h3 className="font-semibold mb-4">Available Plans</h3>
          <div className="grid gap-4 md:grid-cols-3">
            {plans.map((plan) => {
              const isCurrent = plan.slug === (usage?.planSlug || "free");
              return (
                <div key={plan.id} className={`border rounded-lg p-4 ${isCurrent ? "ring-2 ring-blue-500 border-blue-500" : ""}`}>
                  <div className="flex items-center justify-between mb-2">
                    <h4 className="font-semibold">{plan.name}</h4>
                    {isCurrent && <Badge variant="info">Current</Badge>}
                  </div>
                  <p className="text-2xl font-bold mb-1">${(plan.price_cents / 100).toFixed(2)}</p>
                  <p className="text-sm text-gray-500 mb-3">/month</p>
                  <ul className="text-sm space-y-1 mb-4">
                    <li>{plan.monthly_email_limit.toLocaleString()} emails/month</li>
                    {plan.overage_rate_cents > 0 && <li>{plan.overage_rate_cents}c per extra email</li>}
                  </ul>
                  {!isCurrent && (
                    <Button variant={plan.price_cents === 0 ? "secondary" : "primary"} size="sm" className="w-full" onClick={() => handleChangePlan(plan.slug)}>
                      {plan.price_cents === 0 ? "Downgrade" : "Upgrade"}
                    </Button>
                  )}
                </div>
              );
            })}
          </div>
        </div>

        <div className="bg-white border rounded-lg p-6">
          <h3 className="font-semibold mb-4">Invoices</h3>
          {invoices.length === 0 ? (
            <p className="text-sm text-gray-500">No invoices yet</p>
          ) : (
            <div className="space-y-2">
              {invoices.map((inv) => (
                <div key={inv.id} className="flex items-center justify-between border-b pb-2 text-sm">
                  <div>
                    <span className="font-medium">{inv.description || "Invoice"}</span>
                    <span className="text-gray-500 ml-2">
                      {(inv.amount_cents / 100).toFixed(2)} {inv.currency}
                    </span>
                    <Badge variant={inv.status === "paid" ? "success" : inv.status === "pending" ? "warning" : "danger"} className="ml-2">
                      {inv.status}
                    </Badge>
                  </div>
                  <div className="flex items-center gap-2">
                    <span className="text-gray-400 text-xs">{new Date(inv.created_at).toLocaleDateString()}</span>
                    {inv.status === "pending" && (
                      <Button variant="secondary" size="sm" onClick={() => handlePayInvoice(inv.id)}>
                        Pay Now
                      </Button>
                    )}
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>

      <Modal open={changePlanOpen} onClose={() => setChangePlanOpen(false)} title="Change Plan">
        <div className="space-y-3">
          {plans.map((plan) => {
            const isCurrent = plan.slug === (usage?.planSlug || "free");
            return (
              <button
                key={plan.id}
                onClick={() => handleChangePlan(plan.slug)}
                disabled={isCurrent}
                className={`w-full text-left p-4 rounded-lg border transition-colors ${isCurrent ? "bg-gray-50 border-gray-200 cursor-not-allowed" : "hover:border-blue-300 hover:bg-blue-50"}`}
              >
                <div className="flex items-center justify-between">
                  <span className="font-semibold">{plan.name}</span>
                  <span className="text-lg font-bold">${(plan.price_cents / 100).toFixed(2)}/mo</span>
                </div>
                <p className="text-sm text-gray-500 mt-1">{plan.monthly_email_limit.toLocaleString()} emails/month</p>
              </button>
            );
          })}
        </div>
      </Modal>
    </PageShell>
  );
}
