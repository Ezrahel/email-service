import { db } from "@email-service/database";
import { sql } from "kysely";

export interface OverviewResult {
  period: string;
  sent: number; delivered: number; bounced: number; complained: number; opened: number; clicked: number;
  deliveryRate: number; bounceRate: number; openRate: number; clickRate: number;
}

export interface UsageResult {
  total_sent: number; delivered: number; bounced: number; opened: number; clicked: number;
}

export interface ActivityPoint {
  created_at: Date; count: string | number | bigint;
}

export interface ProviderBreakdown {
  provider_type: string; count: number; delivered: number; bounced: number;
}

export class AnalyticsService {
  private thirtyDaysAgo(): Date {
    return new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
  }

  async overview(organizationId: string): Promise<OverviewResult> {
    const ago = this.thirtyDaysAgo();
    const [sent, delivered, bounced, complained, opened, clicked] = await Promise.all([
      db.selectFrom("email_messages").select((eb) => eb.fn.count("id").as("count")).where("organization_id", "=", organizationId).where("created_at", ">=", ago).executeTakeFirstOrThrow(),
      db.selectFrom("deliveries").innerJoin("email_messages", "email_messages.id", "deliveries.email_message_id").select((eb) => eb.fn.count("deliveries.id").as("count")).where("email_messages.organization_id", "=", organizationId).where("deliveries.status", "=", "delivered").where("deliveries.delivered_at", ">=", ago).executeTakeFirstOrThrow(),
      db.selectFrom("deliveries").innerJoin("email_messages", "email_messages.id", "deliveries.email_message_id").select((eb) => eb.fn.count("deliveries.id").as("count")).where("email_messages.organization_id", "=", organizationId).where("deliveries.status", "=", "bounced").where("deliveries.created_at", ">=", ago).executeTakeFirstOrThrow(),
      db.selectFrom("email_metrics").innerJoin("email_messages", "email_messages.id", "email_metrics.email_message_id").select((eb) => eb.fn.count("email_metrics.id").as("count")).where("email_messages.organization_id", "=", organizationId).where("email_metrics.is_complained", "=", true).where("email_metrics.created_at", ">=", ago).executeTakeFirstOrThrow(),
      db.selectFrom("email_metrics").innerJoin("email_messages", "email_messages.id", "email_metrics.email_message_id").select((eb) => eb.fn.count("email_metrics.id").as("count")).where("email_messages.organization_id", "=", organizationId).where("email_metrics.is_opened", "=", true).where("email_metrics.created_at", ">=", ago).executeTakeFirstOrThrow(),
      db.selectFrom("email_metrics").innerJoin("email_messages", "email_messages.id", "email_metrics.email_message_id").select((eb) => eb.fn.count("email_metrics.id").as("count")).where("email_messages.organization_id", "=", organizationId).where("email_metrics.is_clicked", "=", true).where("email_metrics.created_at", ">=", ago).executeTakeFirstOrThrow(),
    ]);
    const s = Number(sent.count);
    const d = Number(delivered.count);
    return {
      period: "30d", sent: s, delivered: d, bounced: Number(bounced.count),
      complained: Number(complained.count), opened: Number(opened.count), clicked: Number(clicked.count),
      deliveryRate: s > 0 ? (d / s) * 100 : 0, bounceRate: s > 0 ? (Number(bounced.count) / s) * 100 : 0,
      openRate: d > 0 ? (Number(opened.count) / d) * 100 : 0, clickRate: d > 0 ? (Number(clicked.count) / d) * 100 : 0,
    };
  }

  async usage(organizationId: string): Promise<UsageResult> {
    const ago = this.thirtyDaysAgo();
    const stats = await db.selectFrom("email_messages").select([
      (eb) => eb.fn.count("id").as("total_sent"),
      sql<number>`COUNT(CASE WHEN status = 'delivered' THEN 1 END)`.as("delivered"),
      sql<number>`COUNT(CASE WHEN status = 'bounced' THEN 1 END)`.as("bounced"),
      sql<number>`COUNT(CASE WHEN status = 'opened' THEN 1 END)`.as("opened"),
      sql<number>`COUNT(CASE WHEN status = 'clicked' THEN 1 END)`.as("clicked"),
    ]).where("organization_id", "=", organizationId).where("created_at", ">=", ago).executeTakeFirstOrThrow();
    return stats as unknown as UsageResult;
  }

  async providers(organizationId: string): Promise<ProviderBreakdown[]> {
    return db.selectFrom("deliveries").innerJoin("email_messages", "email_messages.id", "deliveries.email_message_id").select([
      "deliveries.provider_type",
      (eb) => eb.fn.count("deliveries.id").as("count"),
      sql<number>`COUNT(CASE WHEN deliveries.status = 'delivered' THEN 1 END)`.as("delivered"),
      sql<number>`COUNT(CASE WHEN deliveries.status = 'bounced' THEN 1 END)`.as("bounced"),
    ]).where("email_messages.organization_id", "=", organizationId).groupBy("deliveries.provider_type").execute() as unknown as ProviderBreakdown[];
  }

  async activity(organizationId: string): Promise<ActivityPoint[]> {
    const ago = this.thirtyDaysAgo();
    return db.selectFrom("email_messages").select(["created_at", (eb) => eb.fn.count("id").as("count")]).where("organization_id", "=", organizationId).where("created_at", ">=", ago).groupBy("created_at").orderBy("created_at", "asc").execute();
  }
}
