import { createWorker, QUEUE_NAMES, type AnalyticsRollupJob } from "@email-service/queue";
import { db } from "@email-service/database";
import { logger } from "@email-service/logger";
import { sql } from "kysely";

async function rollupMetrics(job: { organizationId: string; granularity: "1m" | "5m" | "1h" | "1d"; date: string }): Promise<void> {
  const { organizationId, granularity } = job;

  const intervalMap: Record<string, string> = {
    "1m": "1 minute", "5m": "5 minutes", "1h": "1 hour", "1d": "1 day",
  };
  const interval = intervalMap[granularity];
  if (!interval) return;

  const bucket = sql<Date>`date_trunc(${granularity === "5m" ? "'5 minutes'" : granularity === "1m" ? "'minute'" : granularity === "1h" ? "'hour'" : "'day'"}, created_at)`;

  const results = await db.selectFrom("email_messages").select((eb) => [
    bucket.as("bucket"),
    eb.fn.count<number>("id").as("total_count"),
    eb.fn.count<number>("id").filterWhere("status", "=", "delivered").as("delivered_count"),
    eb.fn.count<number>("id").filterWhere("status", "=", "failed").as("failed_count"),
    eb.fn.count<number>("id").filterWhere("status", "=", "bounced").as("bounced_count"),
  ]).where("organization_id", "=", organizationId).where("created_at", ">=", new Date(Date.now() - 3600000)).groupBy(sql`1`).execute();

  for (const row of results) {
    const existing = await db.selectFrom("rollup_1m").select("id").where("organization_id", "=", organizationId).where("metric", "=", "email_status").where("bucket", "=", row.bucket).executeTakeFirst();
    if (existing) {
      await db.updateTable("rollup_1m").set({
        count: Number(row.total_count), error_count: Number(row.failed_count),
        updated_at: new Date(),
      }).where("id", "=", existing.id).execute();
    } else {
      await db.insertInto("rollup_1m").values({
        id: crypto.randomUUID(), organization_id: organizationId, metric: "email_status",
        bucket: row.bucket, count: Number(row.total_count), error_count: Number(row.failed_count),
        created_at: new Date(), updated_at: new Date(),
      }).execute();
    }
  }
  logger.debug({ organizationId, granularity }, "Rollup complete");
}

import crypto from "node:crypto";

createWorker<AnalyticsRollupJob>(QUEUE_NAMES.ANALYTICS, (job) => rollupMetrics(job.data), { concurrency: 2, lockDuration: 120000 });

logger.info("Analytics processor workers started");
