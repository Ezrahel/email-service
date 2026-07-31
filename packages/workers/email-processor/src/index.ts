import { createWorker, QUEUE_NAMES, type EmailSubmissionJob, addJob } from "@resendbyte/queue";
import { db, sql } from "@resendbyte/database";
import { ProviderRegistry, SmtpAdapter, SendGridAdapter, MailgunAdapter, SESAdapter, PostmarkAdapter } from "@resendbyte/domain";
import type { SendEmailMessage } from "@resendbyte/types";
import { env } from "@resendbyte/config";
import { logger } from "@resendbyte/logger";
import { decryptSecret } from "@resendbyte/crypto";
import crypto from "node:crypto";

class NoProviderConfigError extends Error {
  constructor() {
    super("No active provider configuration available");
    this.name = "NoProviderConfigError";
  }
}

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
      const apiKey = decryptSecret(config.credentials_ciphertext);
      registry.setConfig(config.provider_type as any, {
        apiKey,
        ...config.settings,
      } as any);
    } catch {
      // skip unregistered providers
    }
  }
}

async function resolveTrackingDomain(domainId: string | null | undefined): Promise<string> {
  if (domainId) {
    const domain = await db.selectFrom("domains").select("tracking_domain").where("id", "=", domainId).executeTakeFirst();
    if (domain?.tracking_domain) return domain.tracking_domain;
  }
  return env.PUBLIC_URL.replace(/^https?:\/\//, "");
}

function injectTracking(html: string, emailId: string, trackingDomain: string, protocol: string): string {
  const trackingBase = `${protocol}://${trackingDomain}/track`;

  const openPixel = `<img src="${trackingBase}/open/${emailId}.png" width="1" height="1" style="display:none" alt="" />`;

  const clickTracked = html.replace(
    /<a\s+([^>]*?)href="(https?:\/\/[^"]+)"([^>]*?)>/gi,
    (match, before, url, after) => {
      const encoded = encodeURIComponent(url);
      return `<a ${before}href="${trackingBase}/click/${emailId}?redirect=${encoded}"${after} rel="noopener noreferrer">`;
    }
  );

  return clickTracked + openPixel;
}

async function simulateSandboxSend(email: any, deliveryId: string, now: Date): Promise<void> {
  const simulatedMessageId = `<sandbox-${crypto.randomUUID()}@resendbyte>`;

  await db.updateTable("deliveries").set({
    provider_message_id: simulatedMessageId,
    status: "delivered",
    delivered_at: now,
    updated_at: now,
  }).where("id", "=", deliveryId).execute();

  await db.updateTable("email_messages").set({
    status: "delivered",
    message_id: simulatedMessageId,
    delivered_at: now,
    updated_at: now,
  }).where("id", "=", email.id).execute();

  await db.updateTable("email_metrics").set({
    is_delivered: true,
    updated_at: now,
  }).where("email_message_id", "=", email.id).execute();
}

async function getProviderConfigId(): Promise<string> {
  const config = await db.selectFrom("provider_configs").select("id").where("is_active", "=", true).where("deleted_at", "is", null).executeTakeFirst();
  if (!config?.id) {
    throw new NoProviderConfigError();
  }
  return config.id;
}

async function upsertEmailMetrics(emailId: string, deliveryId: string, now: Date): Promise<void> {
  await sql`
    INSERT INTO email_metrics (id, email_message_id, delivery_id, is_delivered, is_bounced, is_opened, is_clicked, is_complained, is_unsubscribed, open_count, click_count, created_at, updated_at)
    VALUES (${crypto.randomUUID()}, ${emailId}, ${deliveryId}, false, false, false, false, false, false, 0, 0, ${now}, ${now})
    ON CONFLICT (email_message_id) DO UPDATE SET delivery_id = EXCLUDED.delivery_id, updated_at = EXCLUDED.updated_at
  `.execute(db);
}

async function sendEmail(job: { emailMessageId: string; organizationId: string; environment?: string }): Promise<void> {
  const email = await db.selectFrom("email_messages")
    .selectAll()
    .where("id", "=", job.emailMessageId)
    .where("deleted_at", "is", null)
    .executeTakeFirst();
  if (!email) {
    logger.warn({ emailMessageId: job.emailMessageId }, "Email message not found");
    return;
  }
  if (email.status !== "queued" && email.status !== "scheduled") return;

  const deliveryId = crypto.randomUUID();
  const now = new Date();

  let providerConfigId: string;
  try {
    providerConfigId = await getProviderConfigId();
  } catch (error) {
    const msg = error instanceof Error ? error.message : String(error);
    logger.error({ emailMessageId: email.id, error: msg }, "Skipping email: no active provider configuration");
    await db.updateTable("email_messages").set({
      status: "failed",
      failed_at: now,
      failure_reason: msg,
      retry_count: email.retry_count + 1,
      updated_at: now,
    }).where("id", "=", email.id).execute();
    return;
  }

  await db.insertInto("deliveries").values({
    id: deliveryId, email_message_id: email.id, provider_config_id: providerConfigId,
    provider_type: "smtp" as any, status: "sending", retry_count: 0, scheduled_at: now,
    created_at: now, updated_at: now,
  }).execute();

  const isSandbox = job.environment === "sandbox";

  await upsertEmailMetrics(email.id, deliveryId, now);

  if (isSandbox) {
    logger.info({ emailMessageId: job.emailMessageId }, "Sandbox mode — simulating email send");
    await simulateSandboxSend(email, deliveryId, now);
    return;
  }

  const trackingDomain = await resolveTrackingDomain(email.domain_id);
  const protocol = env.PUBLIC_URL.startsWith("https") ? "https" : "http";
  let htmlBody = email.html_body || undefined;
  if (htmlBody) {
    htmlBody = injectTracking(htmlBody, email.id, trackingDomain, protocol);
  }

  const message: SendEmailMessage = {
    from: { email: email.from_address }, to: [{ email: email.to_address }],
    subject: email.subject, html: htmlBody,
    text: email.text_body || undefined, tags: email.tags,
  };

  try {
    const response = await registry.send(message);
    const succeeded = response.success;
    await db.updateTable("deliveries").set({
      provider_message_id: response.messageId,
      status: succeeded ? "delivered" : "failed",
      delivered_at: succeeded ? now : null, failed_at: succeeded ? null : now,
      failure_reason: response.error || null, updated_at: now,
    }).where("id", "=", deliveryId).execute();

    await db.updateTable("email_messages").set({
      status: succeeded ? "delivered" : "failed", message_id: response.messageId || null,
      delivered_at: succeeded ? now : null, failed_at: succeeded ? null : now,
      failure_reason: response.error || null, retry_count: email.retry_count + 1, updated_at: now,
    }).where("id", "=", email.id).execute();

    await db.updateTable("email_metrics").set({
      is_delivered: succeeded,
      updated_at: now,
    }).where("email_message_id", "=", email.id).execute();
  } catch (error) {
    const msg = error instanceof Error ? error.message : String(error);
    await db.updateTable("deliveries").set({ status: "failed", failed_at: now, failure_reason: msg, updated_at: now }).where("id", "=", deliveryId).execute();
    const newStatus = email.retry_count >= email.max_retries ? "failed" : "retrying";
    await db.updateTable("email_messages").set({
      status: newStatus, retry_count: email.retry_count + 1, failure_reason: msg, updated_at: now,
    }).where("id", "=", email.id).execute();

    await db.updateTable("email_metrics").set({
      is_bounced: true,
      updated_at: now,
    }).where("email_message_id", "=", email.id).execute();

    if (newStatus === "retrying") {
      await addJob(QUEUE_NAMES.DELIVERY_RETRY, "delivery:retry", {
        deliveryId,
        retryCount: email.retry_count,
      });
    }
  }
}

async function startWorkers(): Promise<void> {
  await loadProviderConfigs();

  createWorker<EmailSubmissionJob>(QUEUE_NAMES.EMAIL_CRITICAL, (job) => sendEmail(job.data), { concurrency: 20 });
  createWorker<EmailSubmissionJob>(QUEUE_NAMES.EMAIL_HIGH, (job) => sendEmail(job.data), { concurrency: 15 });
  createWorker<EmailSubmissionJob>(QUEUE_NAMES.EMAIL_DEFAULT, (job) => sendEmail(job.data), { concurrency: 10 });
  createWorker<EmailSubmissionJob>(QUEUE_NAMES.EMAIL_LOW, (job) => sendEmail(job.data), { concurrency: 5 });

  logger.info("Email processor workers started");
}

startWorkers().catch((err) => logger.error({ error: String(err) }, "Failed to start email processor workers"));
