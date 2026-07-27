import crypto from "node:crypto";
import { createWorker, QUEUE_NAMES, type DeliveryProcessJob, type DeliveryRetryJob } from "@email-service/queue";
import { db } from "@email-service/database";
import { logger } from "@email-service/logger";

async function processDelivery(job: { deliveryId: string; providerConfigId: string }): Promise<void> {
  const delivery = await db.selectFrom("deliveries").selectAll().where("id", "=", job.deliveryId).executeTakeFirst();
  if (!delivery) return;
  const deliveryStatus: string = delivery.status;
  if (deliveryStatus !== "pending") return;

  const email = await db.selectFrom("email_messages").selectAll().where("id", "=", delivery.email_message_id).executeTakeFirst();
  if (!email) return;

  await db.updateTable("deliveries").set({ status: "sending", sent_at: new Date(), updated_at: new Date() }).where("id", "=", delivery.id).execute();

  try {
    const existing = await db.selectFrom("email_metrics").select("id").where("email_message_id", "=", email.id).executeTakeFirst();
    if (!existing) {
      const deliveryStatusCheck: string = delivery.status;
      await db.insertInto("email_metrics").values({
        id: crypto.randomUUID(), email_message_id: email.id, delivery_id: delivery.id,
        is_delivered: deliveryStatusCheck === "delivered",
        is_bounced: deliveryStatusCheck === "bounced",
        is_opened: false, is_clicked: false, is_complained: false, is_unsubscribed: false,
        open_count: 0, click_count: 0,
        created_at: new Date(), updated_at: new Date(),
      }).execute();
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

createWorker<DeliveryProcessJob>(QUEUE_NAMES.DELIVERY_RETRY, (job) => processDelivery(job.data), { concurrency: 5 });
createWorker<DeliveryRetryJob>(QUEUE_NAMES.DELIVERY_RETRY, (job) => retryDelivery(job.data), { concurrency: 5 });

logger.info("Delivery processor workers started");
