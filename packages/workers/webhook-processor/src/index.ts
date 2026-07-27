import { createWorker, QUEUE_NAMES, type WebhookDeliveryJob, type WebhookRetryJob } from "@email-service/queue";
import { db } from "@email-service/database";
import { logger } from "@email-service/logger";

async function deliverWebhook(job: { webhookDeliveryId: string }): Promise<void> {
  const delivery = await db.selectFrom("webhook_deliveries").selectAll().where("id", "=", job.webhookDeliveryId).executeTakeFirst();
  if (!delivery || delivery.delivered_at) return;

  const webhook = await db.selectFrom("webhooks").selectAll().where("id", "=", delivery.webhook_id).executeTakeFirst();
  if (!webhook || webhook.status !== "active") return;

  try {
    const response = await fetch(webhook.url, {
      method: "POST",
      headers: { "Content-Type": "application/json", "User-Agent": "EmailService-Webhook/1.0" },
      body: JSON.stringify(delivery.payload),
      signal: AbortSignal.timeout(10000),
    });

    const responseBody = await response.text();
    if (response.ok) {
      await db.updateTable("webhook_deliveries").set({
        response_status: response.status, response_body: responseBody,
        delivered_at: new Date(),
      }).where("id", "=", delivery.id).execute();
      await db.updateTable("webhooks").set({
        last_success_at: new Date(), failure_count: 0, updated_at: new Date(),
      }).where("id", "=", webhook.id).execute();
    } else {
      await db.updateTable("webhook_deliveries").set({
        response_status: response.status, response_body: responseBody,
        error_message: `HTTP ${response.status}`, attempt: delivery.attempt + 1,
        next_retry_at: new Date(Date.now() + 60000),
      }).where("id", "=", delivery.id).execute();
      await db.updateTable("webhooks").set({
        last_failure_at: new Date(), last_failure_reason: `HTTP ${response.status}`,
        failure_count: webhook.failure_count + 1, updated_at: new Date(),
      }).where("id", "=", webhook.id).execute();
    }
  } catch (error) {
    const msg = error instanceof Error ? error.message : String(error);
    await db.updateTable("webhook_deliveries").set({
      error_message: msg, attempt: delivery.attempt + 1,
      next_retry_at: new Date(Date.now() + 60000),
    }).where("id", "=", delivery.id).execute();
    await db.updateTable("webhooks").set({
      last_failure_at: new Date(), last_failure_reason: msg,
      failure_count: webhook.failure_count + 1, updated_at: new Date(),
    }).where("id", "=", webhook.id).execute();
  }
}

async function retryWebhook(job: { webhookDeliveryId: string; retryCount: number }): Promise<void> {
  const delivery = await db.selectFrom("webhook_deliveries").selectAll().where("id", "=", job.webhookDeliveryId).executeTakeFirst();
  if (!delivery || delivery.delivered_at || delivery.attempt >= 10) return;
  await deliverWebhook({ webhookDeliveryId: job.webhookDeliveryId });
}

createWorker<WebhookDeliveryJob>(QUEUE_NAMES.WEBHOOK_DELIVERY, (job) => deliverWebhook(job.data), { concurrency: 20 });
createWorker<WebhookRetryJob>(QUEUE_NAMES.WEBHOOK_RETRY, (job) => retryWebhook(job.data), { concurrency: 10 });

logger.info("Webhook processor workers started");
