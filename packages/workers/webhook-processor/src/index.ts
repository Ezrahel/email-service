import { createWorker, QUEUE_NAMES, addJob, type WebhookDeliveryJob, type WebhookRetryJob } from "@resendbyte/queue";
import { db, sql } from "@resendbyte/database";
import { logger } from "@resendbyte/logger";
import { generateWebhookSignature, decryptSecret } from "@resendbyte/crypto";

const MAX_RESPONSE_BODY_LENGTH = 65536;

async function deliverWebhook(job: { webhookDeliveryId: string }): Promise<void> {
  const delivery = await db.selectFrom("webhook_deliveries").selectAll().where("id", "=", job.webhookDeliveryId).executeTakeFirst();
  if (!delivery) {
    logger.warn({ webhookDeliveryId: job.webhookDeliveryId }, "Webhook delivery not found, skipping");
    return;
  }
  if (delivery.delivered_at) return;

  const webhook = await db.selectFrom("webhooks").selectAll().where("id", "=", delivery.webhook_id).executeTakeFirst();
  if (!webhook || webhook.status !== "active") {
    logger.warn({ webhookId: delivery.webhook_id }, "Webhook not active, skipping delivery");
    return;
  }

  const payloadBody = JSON.stringify(delivery.payload);
  const headers: Record<string, string> = {
    "Content-Type": "application/json",
    "User-Agent": "EmailService-Webhook/1.0",
  };

  if (webhook.secret_ciphertext) {
    const secret = decryptSecret(webhook.secret_ciphertext);
    if (secret) {
      headers["X-Email-Service-Signature"] = generateWebhookSignature(payloadBody, secret);
    }
  }

  try {
    const response = await fetch(webhook.url, {
      method: "POST",
      headers,
      body: payloadBody,
      signal: AbortSignal.timeout(10000),
    });

    const responseBody = (await response.text()).slice(0, MAX_RESPONSE_BODY_LENGTH);
    if (response.ok) {
      await db.updateTable("webhook_deliveries").set({
        response_status: response.status, response_body: responseBody,
        delivered_at: new Date(),
      }).where("id", "=", delivery.id).execute();
      await db.updateTable("webhooks").set({
        last_success_at: new Date(), failure_count: 0, updated_at: new Date(),
      }).where("id", "=", webhook.id).execute();
    } else {
      const newAttempt = delivery.attempt + 1;
      await db.updateTable("webhook_deliveries").set({
        response_status: response.status, response_body: responseBody,
        error_message: `HTTP ${response.status}`, attempt: newAttempt,
        next_retry_at: new Date(Date.now() + getBackoff(newAttempt)),
      }).where("id", "=", delivery.id).execute();
      await sql`UPDATE "webhooks" SET failure_count = failure_count + 1, last_failure_at = ${new Date()}, last_failure_reason = ${`HTTP ${response.status}`}, updated_at = ${new Date()} WHERE "id" = ${webhook.id}`.execute(db);

      if (newAttempt < 10) {
        await addJob(QUEUE_NAMES.WEBHOOK_RETRY, "webhook:retry", {
          webhookDeliveryId: delivery.id,
          retryCount: newAttempt,
        }, { delay: getBackoff(newAttempt) });
      }
    }
  } catch (error) {
    const msg = error instanceof Error ? error.message : String(error);
    const newAttempt = delivery.attempt + 1;
    await db.updateTable("webhook_deliveries").set({
      error_message: msg, attempt: newAttempt,
      next_retry_at: new Date(Date.now() + getBackoff(newAttempt)),
    }).where("id", "=", delivery.id).execute();
    await sql`UPDATE "webhooks" SET failure_count = failure_count + 1, last_failure_at = ${new Date()}, last_failure_reason = ${msg}, updated_at = ${new Date()} WHERE "id" = ${webhook.id}`.execute(db);

    if (newAttempt < 10) {
      await addJob(QUEUE_NAMES.WEBHOOK_RETRY, "webhook:retry", {
        webhookDeliveryId: delivery.id,
        retryCount: newAttempt,
      }, { delay: getBackoff(newAttempt) });
    }
  }
}

function getBackoff(attempt: number): number {
  return Math.min(Math.pow(2, attempt) * 10000, 3600000);
}

async function retryWebhook(job: { webhookDeliveryId: string; retryCount: number }): Promise<void> {
  const delivery = await db.selectFrom("webhook_deliveries").selectAll().where("id", "=", job.webhookDeliveryId).executeTakeFirst();
  if (!delivery || delivery.delivered_at || delivery.attempt >= 10) return;
  await deliverWebhook({ webhookDeliveryId: job.webhookDeliveryId });
}

createWorker<WebhookDeliveryJob>(QUEUE_NAMES.WEBHOOK_DELIVERY, (job) => deliverWebhook(job.data), { concurrency: 20 });
createWorker<WebhookRetryJob>(QUEUE_NAMES.WEBHOOK_RETRY, (job) => retryWebhook(job.data), { concurrency: 10 });

logger.info("Webhook processor workers started");
