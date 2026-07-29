import crypto from "node:crypto";
import { createWorker, QUEUE_NAMES, type DeliveryProcessJob, type DeliveryRetryJob } from "@resendbyte/queue";
import { db, sql } from "@resendbyte/database";
import { logger } from "@resendbyte/logger";
import { SuppressionService } from "@resendbyte/domain";

const suppressionService = new SuppressionService();

async function processDelivery(job: { deliveryId: string; providerConfigId: string }): Promise<void> {
  const delivery = await db.selectFrom("deliveries").selectAll().where("id", "=", job.deliveryId).executeTakeFirst();
  if (!delivery || !delivery.status) return;

  const email = await db.selectFrom("email_messages").selectAll().where("id", "=", delivery.email_message_id).executeTakeFirst();
  if (!email) return;

  try {
    const existing = await db.selectFrom("email_metrics").select("id").where("email_message_id", "=", email.id).executeTakeFirst();
    if (!existing) {
      const isBounced = delivery.status === "bounced";
      const isDelivered = delivery.status === "delivered";
      await sql`
        INSERT INTO email_metrics (id, email_message_id, delivery_id, is_delivered, is_bounced, is_opened, is_clicked, is_complained, is_unsubscribed, open_count, click_count, created_at, updated_at)
        VALUES (${crypto.randomUUID()}, ${email.id}, ${delivery.id}, ${isDelivered}, ${isBounced}, false, false, false, false, 0, 0, ${new Date()}, ${new Date()})
        ON CONFLICT (email_message_id) DO NOTHING
      `.execute(db);

      if (isBounced && email.organization_id) {
        await suppressionService.add(email.organization_id, email.to_address, "hard_bounce", "automatic").catch((err) => {
          logger.error({ error: String(err), email: email.to_address }, "Failed to auto-suppress bounced email");
        });
      }
    }
    logger.debug({ deliveryId: job.deliveryId }, "Delivery processed");
  } catch (error) {
    logger.error({ error: String(error), deliveryId: job.deliveryId }, "Delivery processing failed");
  }
}

async function retryDelivery(job: { deliveryId: string; retryCount: number }): Promise<void> {
  const delivery = await db.selectFrom("deliveries").selectAll().where("id", "=", job.deliveryId).executeTakeFirst();
  if (!delivery || delivery.status !== "failed") return;

  if (delivery.retry_count >= 5) {
    await db.updateTable("deliveries").set({ status: "permanently_failed", updated_at: new Date() }).where("id", "=", delivery.id).execute();
    return;
  }

  await db.updateTable("deliveries").set({
    status: "retrying", retry_count: delivery.retry_count + 1,
    next_retry_at: new Date(Date.now() + Math.pow(2, job.retryCount) * 60000),
    updated_at: new Date(),
  }).where("id", "=", delivery.id).execute();
}

createWorker(QUEUE_NAMES.DELIVERY_RETRY, (bullJob) => {
  if (bullJob.name === "delivery:process") return processDelivery((bullJob as any).data);
  return retryDelivery((bullJob as any).data);
}, { concurrency: 5 });

logger.info("Delivery processor workers started");
