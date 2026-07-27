import { createWorker, QUEUE_NAMES, type EmailSubmissionJob } from "@email-service/queue";
import { db } from "@email-service/database";
import { ProviderRegistry, SmtpAdapter, SendGridAdapter, MailgunAdapter, SESAdapter, PostmarkAdapter } from "@email-service/domain";
import type { SendEmailMessage } from "@email-service/types";
import { logger } from "@email-service/logger";
import crypto from "node:crypto";

const registry = new ProviderRegistry();
registry.register(new SmtpAdapter(), { priority: 10, weight: 1 });
registry.register(new SendGridAdapter(), { priority: 5, weight: 3 });
registry.register(new MailgunAdapter(), { priority: 5, weight: 2 });
registry.register(new SESAdapter(), { priority: 5, weight: 2 });
registry.register(new PostmarkAdapter(), { priority: 5, weight: 2 });

async function loadProviderConfigs(): Promise<void> {
  const configs = await db.selectFrom("provider_configs").selectAll().where("is_active", "=", true).where("deleted_at", "is", null).execute();
  for (const config of configs) {
    try {
      registry.setConfig(config.provider_type as any, {
        apiKey: config.credentials_ciphertext,
        ...config.settings,
      } as any);
    } catch {
      // skip unregistered providers
    }
  }
}

async function sendEmail(job: { emailMessageId: string; organizationId: string }): Promise<void> {
  const email = await db.selectFrom("email_messages").selectAll().where("id", "=", job.emailMessageId).where("deleted_at", "is", null).executeTakeFirst();
  if (!email) {
    logger.warn({ emailMessageId: job.emailMessageId }, "Email message not found");
    return;
  }
  if (email.status !== "queued") return;

  const deliveryId = crypto.randomUUID();
  const now = new Date();

  await db.insertInto("deliveries").values({
    id: deliveryId, email_message_id: email.id, provider_config_id: crypto.randomUUID(),
    provider_type: "smtp", status: "sending", retry_count: 0, scheduled_at: now,
    created_at: now, updated_at: now,
  }).execute();

  const message: SendEmailMessage = {
    from: { email: email.from_address }, to: [{ email: email.to_address }],
    subject: email.subject, html: email.html_body || undefined,
    text: email.text_body || undefined, tags: email.tags,
  };

  try {
    const response = await registry.send(message);
    const succeeded = response.success;
    await db.updateTable("deliveries").set({
      provider_message_id: response.messageId,
      status: succeeded ? "delivered" : "failed",
      delivered_at: succeeded ? now : null, failed_at: succeeded ? now : null,
      failure_reason: response.error || null, updated_at: now,
    }).where("id", "=", deliveryId).execute();

    await db.updateTable("email_messages").set({
      status: succeeded ? "delivered" : "failed", message_id: response.messageId || null,
      delivered_at: succeeded ? now : null, failed_at: succeeded ? null : now,
      failure_reason: response.error || null, retry_count: email.retry_count + 1, updated_at: now,
    }).where("id", "=", email.id).execute();
  } catch (error) {
    const msg = error instanceof Error ? error.message : String(error);
    await db.updateTable("deliveries").set({ status: "failed", failed_at: now, failure_reason: msg, updated_at: now }).where("id", "=", deliveryId).execute();
    await db.updateTable("email_messages").set({
      status: email.retry_count >= email.max_retries ? "failed" : "retrying",
      retry_count: email.retry_count + 1, failure_reason: msg, updated_at: now,
    }).where("id", "=", email.id).execute();
  }
}

createWorker<EmailSubmissionJob>(QUEUE_NAMES.EMAIL_CRITICAL, (job) => sendEmail(job.data), { concurrency: 20 });
createWorker<EmailSubmissionJob>(QUEUE_NAMES.EMAIL_HIGH, (job) => sendEmail(job.data), { concurrency: 15 });
createWorker<EmailSubmissionJob>(QUEUE_NAMES.EMAIL_DEFAULT, (job) => sendEmail(job.data), { concurrency: 10 });
createWorker<EmailSubmissionJob>(QUEUE_NAMES.EMAIL_LOW, (job) => sendEmail(job.data), { concurrency: 5 });

loadProviderConfigs().catch((err) => logger.error({ error: String(err) }, "Failed to load provider configs"));
logger.info("Email processor workers started");
