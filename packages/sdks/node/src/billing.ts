import type { HttpClient } from "./client.js";
import type { Plan, Subscription, UsageInfo, Invoice } from "./types.js";

export class BillingResource {
  constructor(private client: HttpClient) {}

  async listPlans(): Promise<Plan[]> {
    return this.client.get("/api/v1/billing/plans");
  }

  async getSubscription(): Promise<{ subscription: Subscription | null; usage: UsageInfo }> {
    return this.client.get("/api/v1/billing/subscription");
  }

  async changePlan(planSlug: string): Promise<void> {
    return this.client.post("/api/v1/billing/subscription/change", { planSlug });
  }

  async enableOverage(enabled: boolean): Promise<void> {
    return this.client.post("/api/v1/billing/overage", { enabled });
  }

  async listInvoices(params?: { page?: number; perPage?: number }): Promise<{ data: Invoice[]; meta: any }> {
    const searchParams = new URLSearchParams();
    if (params?.page) searchParams.set("page", String(params.page));
    if (params?.perPage) searchParams.set("perPage", String(params.perPage));
    const qs = searchParams.toString();
    return this.client.get(`/api/v1/billing/invoices${qs ? `?${qs}` : ""}`);
  }

  async generateOverageInvoice(): Promise<{ id: string; amountCents: number }> {
    return this.client.post("/api/v1/billing/invoices/generate-overage");
  }

  async payInvoice(invoiceId: string): Promise<{ authorizationUrl: string; reference: string }> {
    return this.client.post(`/api/v1/billing/invoices/${invoiceId}/pay`);
  }
}
