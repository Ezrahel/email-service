import { db, sql } from "@resendbyte/database";
import { env } from "@resendbyte/config";
import { QuotaExceededError, NotFoundError, ValidationError } from "@resendbyte/errors";
import { logger } from "@resendbyte/logger";

export interface UsageInfo {
  sentThisMonth: number;
  limit: number;
  monthStart: Date;
  overageEnabled: boolean;
  planSlug: string;
  overageBalanceCents: number;
}

export interface PlanInfo {
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

export interface SubscriptionInfo {
  id: string;
  planId: string;
  planName: string;
  planSlug: string;
  status: string;
  periodStart: Date;
  periodEnd: Date;
  cancelAtPeriodEnd: boolean;
  overageBalanceCents: number;
}

export class BillingService {
  async checkQuota(organizationId: string, count: number = 1): Promise<void> {
    const org = await db.selectFrom("organizations")
      .select(["emails_sent_this_month", "monthly_email_limit", "overage_enabled", "suspended_at"])
      .where("id", "=", organizationId)
      .executeTakeFirst();

    if (!org) return;

    if (org.suspended_at) {
      throw new QuotaExceededError("account", 0, { reason: "Account suspended due to payment failure" });
    }

    const projected = (org.emails_sent_this_month ?? 0) + count;

    if (projected > org.monthly_email_limit) {
      if (org.overage_enabled) return;
      throw new QuotaExceededError("monthly_email", org.monthly_email_limit, {
        sent: org.emails_sent_this_month,
        limit: org.monthly_email_limit,
        projected,
      });
    }
  }

  async incrementUsageAndRecordOverage(organizationId: string): Promise<void> {
    const org = await db.selectFrom("organizations")
      .select(["emails_sent_this_month", "monthly_email_limit", "overage_enabled"])
      .where("id", "=", organizationId)
      .executeTakeFirst();

    if (!org) return;

    await sql`
      UPDATE organizations
      SET emails_sent_this_month = emails_sent_this_month + 1
      WHERE id = ${organizationId}
    `.execute(db);

    const sentAfterInc = (org.emails_sent_this_month ?? 0) + 1;

    if (sentAfterInc > org.monthly_email_limit && org.overage_enabled) {
      const sub = await db.selectFrom("subscriptions")
        .select(["id", "overage_balance_cents"])
        .where("organization_id", "=", organizationId)
        .where("status", "=", "active")
        .executeTakeFirst();

      if (sub) {
        await db.updateTable("subscriptions")
          .set((eb) => ({ overage_balance_cents: eb("overage_balance_cents", "+", 1) }))
          .where("id", "=", sub.id)
          .execute();
      }

      await db.insertInto("usage_records").values({
        id: crypto.randomUUID(),
        organization_id: organizationId,
        metric_name: "email_overage",
        period_start: new Date(new Date().getFullYear(), new Date().getMonth(), 1),
        period_end: new Date(new Date().getFullYear(), new Date().getMonth() + 1, 0),
        count: 1,
        metadata: { type: "overage" },
        created_at: new Date(),
      }).execute();
    }
  }

  async getUsage(organizationId: string): Promise<UsageInfo> {
    const org = await db.selectFrom("organizations")
      .select(["emails_sent_this_month", "monthly_email_limit", "month_start_date", "overage_enabled"])
      .where("id", "=", organizationId)
      .executeTakeFirst();

    let planSlug = "free";
    let overageBalanceCents = 0;

    const sub = await db.selectFrom("subscriptions")
      .innerJoin("plans", "plans.id", "subscriptions.plan_id")
      .select(["plans.slug", "subscriptions.overage_balance_cents"])
      .where("subscriptions.organization_id", "=", organizationId)
      .where("subscriptions.status", "=", "active")
      .executeTakeFirst();

    if (sub) {
      planSlug = sub.slug;
      overageBalanceCents = sub.overage_balance_cents;
    }

    return {
      sentThisMonth: org?.emails_sent_this_month ?? 0,
      limit: org?.monthly_email_limit ?? 100000,
      monthStart: org?.month_start_date ?? new Date(),
      overageEnabled: org?.overage_enabled ?? false,
      planSlug,
      overageBalanceCents,
    };
  }

  async listPlans(): Promise<PlanInfo[]> {
    const plans = await db.selectFrom("plans")
      .selectAll()
      .where("is_active", "=", true)
      .orderBy("sort_order")
      .execute();
    return plans.map((p) => ({
      id: p.id,
      name: p.name,
      slug: p.slug,
      description: p.description,
      monthly_email_limit: p.monthly_email_limit,
      price_cents: p.price_cents,
      overage_rate_cents: p.overage_rate_cents,
      features: p.features as Record<string, unknown>,
      sort_order: p.sort_order,
    }));
  }

  async getCurrentSubscription(organizationId: string): Promise<SubscriptionInfo | null> {
    const sub = await db.selectFrom("subscriptions")
      .innerJoin("plans", "plans.id", "subscriptions.plan_id")
      .select([
        "subscriptions.id",
        "subscriptions.plan_id",
        "plans.name as plan_name",
        "plans.slug as plan_slug",
        "subscriptions.status",
        "subscriptions.period_start",
        "subscriptions.period_end",
        "subscriptions.cancel_at_period_end",
        "subscriptions.overage_balance_cents",
      ])
      .where("subscriptions.organization_id", "=", organizationId)
      .where("subscriptions.status", "=", "active")
      .executeTakeFirst();

    if (!sub) return null;

    return {
      id: sub.id,
      planId: sub.plan_id,
      planName: sub.plan_name,
      planSlug: sub.plan_slug,
      status: sub.status,
      periodStart: sub.period_start,
      periodEnd: sub.period_end,
      cancelAtPeriodEnd: sub.cancel_at_period_end,
      overageBalanceCents: sub.overage_balance_cents,
    };
  }

  async changePlan(organizationId: string, planSlug: string): Promise<void> {
    const plan = await db.selectFrom("plans")
      .selectAll()
      .where("slug", "=", planSlug)
      .where("is_active", "=", true)
      .executeTakeFirst();

    if (!plan) throw new NotFoundError("Plan", planSlug);

    const sub = await db.selectFrom("subscriptions")
      .selectAll()
      .where("organization_id", "=", organizationId)
      .where("status", "=", "active")
      .executeTakeFirst();

    const now = new Date();
    const periodEnd = new Date(now.getFullYear(), now.getMonth() + 1, 0, 23, 59, 59);

    if (sub) {
      await db.updateTable("subscriptions")
        .set({
          plan_id: plan.id,
          period_start: sub.period_start,
          period_end: sub.period_end,
          updated_at: now,
        })
        .where("id", "=", sub.id)
        .execute();
    } else {
      await db.insertInto("subscriptions").values({
        id: crypto.randomUUID(),
        organization_id: organizationId,
        plan_id: plan.id,
        status: "active",
        period_start: now,
        period_end: periodEnd,
        cancel_at_period_end: false,
        overage_balance_cents: 0,
        created_at: now,
        updated_at: now,
      }).execute();
    }

    await db.updateTable("organizations")
      .set({ plan_id: plan.id, monthly_email_limit: plan.monthly_email_limit, updated_at: now })
      .where("id", "=", organizationId)
      .execute();

    logger.info({ organizationId, planSlug }, "Plan changed");
  }

  async enableOverage(organizationId: string, enabled: boolean): Promise<void> {
    await db.updateTable("organizations")
      .set({ overage_enabled: enabled, updated_at: new Date() })
      .where("id", "=", organizationId)
      .execute();
  }

  async suspend(organizationId: string, reason: string = "payment_failed"): Promise<void> {
    await db.updateTable("organizations")
      .set({ suspended_at: new Date(), updated_at: new Date() })
      .where("id", "=", organizationId)
      .execute();

    await db.updateTable("subscriptions")
      .set({ status: "past_due", updated_at: new Date() })
      .where("organization_id", "=", organizationId)
      .where("status", "=", "active")
      .execute();

    logger.warn({ organizationId, reason }, "Organization suspended");
  }

  async unsuspend(organizationId: string): Promise<void> {
    await db.updateTable("organizations")
      .set({ suspended_at: null, updated_at: new Date() })
      .where("id", "=", organizationId)
      .execute();

    await db.updateTable("subscriptions")
      .set({ status: "active", updated_at: new Date() })
      .where("organization_id", "=", organizationId)
      .where("status", "=", "past_due")
      .execute();
  }

  async generateOverageInvoice(organizationId: string): Promise<{ id: string; amountCents: number }> {
    const sub = await db.selectFrom("subscriptions")
      .innerJoin("plans", "plans.id", "subscriptions.plan_id")
      .select(["subscriptions.id", "subscriptions.overage_balance_cents", "plans.overage_rate_cents"])
      .where("subscriptions.organization_id", "=", organizationId)
      .where("subscriptions.status", "=", "active")
      .executeTakeFirst();

    if (!sub || sub.overage_balance_cents <= 0) {
      throw new ValidationError("No overage balance to invoice");
    }

    const amountCents = sub.overage_balance_cents * sub.overage_rate_cents;

    const invoice = await db.insertInto("invoices").values({
      id: crypto.randomUUID(),
      organization_id: organizationId,
      subscription_id: sub.id,
      amount_cents: amountCents,
      currency: "NGN",
      status: "pending",
      description: `Overage charges for ${sub.overage_balance_cents} extra emails at ${sub.overage_rate_cents} cents each`,
      created_at: new Date(),
      updated_at: new Date(),
    }).returning("id").executeTakeFirstOrThrow();

    await db.updateTable("subscriptions")
      .set({ overage_balance_cents: 0, updated_at: new Date() })
      .where("id", "=", sub.id)
      .execute();

    return { id: invoice.id, amountCents };
  }

  async listInvoices(organizationId: string, page: number = 1, perPage: number = 20): Promise<{ data: Invoice[]; meta: any }> {
    const offset = (page - 1) * perPage;
    const data = await db.selectFrom("invoices")
      .selectAll()
      .where("organization_id", "=", organizationId)
      .orderBy("created_at", "desc")
      .limit(perPage)
      .offset(offset)
      .execute();

    const countResult = await db.selectFrom("invoices")
      .select(db.fn.countAll<number>().as("count"))
      .where("organization_id", "=", organizationId)
      .execute();

    const total = countResult[0]?.count ?? 0;

    return {
      data,
      meta: { page, perPage, total: Number(total) },
    };
  }

  async initializePaystackPayment(invoiceId: string, organizationId: string): Promise<{ authorizationUrl: string; reference: string }> {
    const invoice = await db.selectFrom("invoices")
      .selectAll()
      .where("id", "=", invoiceId)
      .where("organization_id", "=", organizationId)
      .executeTakeFirst();

    if (!invoice) throw new NotFoundError("Invoice", invoiceId);
    if (invoice.status !== "pending") throw new ValidationError("Invoice is not pending");

    const secretKey = env.PAYSTACK_SECRET_KEY;
    if (!secretKey) throw new ValidationError("Paystack not configured");

    const reference = `inv-${invoice.id}-${Date.now()}`;

    const response = await fetch("https://api.paystack.co/transaction/initialize", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${secretKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        email: await this.getOrgEmail(organizationId),
        amount: invoice.amount_cents,
        reference,
        callback_url: `${env.PUBLIC_URL}/dashboard/billing?invoice=${invoice.id}`,
      }),
    });

    const body = await response.json() as any;
    if (!body.status) {
      logger.error({ paystackResponse: body }, "Paystack init failed");
      throw new ValidationError("Payment initialization failed");
    }

    await db.updateTable("invoices")
      .set({ paystack_reference: reference, updated_at: new Date() })
      .where("id", "=", invoice.id)
      .execute();

    return { authorizationUrl: body.data.authorization_url, reference };
  }

  async handlePaystackWebhook(payload: any): Promise<void> {
    const event = payload.event;
    const data = payload.data;

    if (event === "charge.success") {
      const reference = data.reference;
      const invoice = await db.selectFrom("invoices")
        .selectAll()
        .where("paystack_reference", "=", reference)
        .executeTakeFirst();

      if (invoice && invoice.status === "pending") {
        const amountPaid = data.amount / 100;

        await db.updateTable("invoices")
          .set({
            status: "paid",
            paid_at: new Date(),
            amount_cents: amountPaid,
            updated_at: new Date(),
          })
          .where("id", "=", invoice.id)
          .execute();

        await this.unsuspend(invoice.organization_id);
        logger.info({ invoiceId: invoice.id, organizationId: invoice.organization_id }, "Invoice paid");
      }
    }

    if (event === "subscription.not_renew") {
      const subCode = data.subscription_code;
      const sub = await db.selectFrom("subscriptions")
        .selectAll()
        .where("paystack_subscription_code", "=", subCode)
        .executeTakeFirst();

      if (sub) {
        await db.updateTable("subscriptions")
          .set({ cancel_at_period_end: true, updated_at: new Date() })
          .where("id", "=", sub.id)
          .execute();
      }
    }
  }

  private async getOrgEmail(organizationId: string): Promise<string> {
    const member = await db.selectFrom("memberships")
      .innerJoin("users", "users.id", "memberships.user_id")
      .select("users.email")
      .where("memberships.organization_id", "=", organizationId)
      .where("memberships.role_id", "=", "owner")
      .executeTakeFirst();

    return member?.email ?? "admin@example.com";
  }
}

interface Invoice {
  id: string;
  organization_id: string;
  subscription_id: string | null;
  amount_cents: number;
  currency: string;
  status: string;
  description: string | null;
  period_start: Date | null;
  period_end: Date | null;
  paid_at: Date | null;
  paystack_reference: string | null;
  created_at: Date;
  updated_at: Date;
}
