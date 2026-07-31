import type { FastifyInstance } from "fastify";
import { z } from "zod";
import { AuthService, EmailService, DomainService, TemplateService, WebhookService, AnalyticsService, SuppressionService, StorageService, BillingService, AuditService } from "@resendbyte/domain";
import { db } from "@resendbyte/database";
import { ValidationError, NotFoundError, InternalError, QuotaExceededError, UnauthorizedError } from "@resendbyte/errors";
import { verifyWebhookSignature } from "@resendbyte/crypto";
import { env } from "@resendbyte/config";
import { requireScope } from "../middleware/auth.js";
import { validateBody, validateQuery, validateParams, paginationSchema, idParamSchema } from "../middleware/validation.js";
import { addJob, QUEUE_NAMES } from "@resendbyte/queue";
import crypto from "node:crypto";

const authService = new AuthService();
const emailService = new EmailService();
const domainService = new DomainService();
const templateService = new TemplateService();
const webhookService = new WebhookService();
const analyticsService = new AnalyticsService();
const suppressionService = new SuppressionService();
const storageService = new StorageService();
const billingService = new BillingService();
const auditService = new AuditService();

const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8).max(128),
});
const refreshSchema = z.object({
  refreshToken: z.string().min(10),
});
const createAPIKeySchema = z.object({
  name: z.string().min(1).max(255),
  scopes: z.array(z.string()).default(["email:send", "email:read", "template:read", "template:write", "webhook:read", "webhook:write", "api_key:read", "api_key:write", "analytics:read"]),
  expiresAt: z.string().datetime().optional(),
  allowedIPs: z.array(z.string().regex(/^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9])\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9])$/)).optional(),
  environment: z.enum(["live", "sandbox"]).optional(),
});
const createWebhookSchema = z.object({
  url: z.string().url(),
  events: z.array(z.string()).min(1),
  secret: z.string().optional(),
});
const sendEmailSchema = z.object({
  from: z.string().email(),
  to: z.string().email().or(z.array(z.string().email())),
  subject: z.string().min(1).max(998),
  html: z.string().optional(),
  text: z.string().optional(),
  replyTo: z.string().email().optional(),
  tags: z.array(z.string()).optional(),
  idempotencyKey: z.string().optional(),
  scheduledAt: z.string().datetime().optional(),
  attachmentIds: z.array(z.string().uuid()).optional(),
});
const sendTemplateSchema = z.object({
  to: z.string().email(),
  variables: z.record(z.string()).optional(),
});

export async function authRoutes(app: FastifyInstance): Promise<void> {
  app.post("/auth/login", { preHandler: [validateBody(loginSchema)] }, async (request, reply) => {
    const { email, password } = request.body as z.infer<typeof loginSchema>;
    const result = await authService.login(email, password);
    reply.status(200).send({ data: result });
  });

  app.post("/auth/refresh", { preHandler: [validateBody(refreshSchema)] }, async (request, reply) => {
    const { refreshToken } = request.body as z.infer<typeof refreshSchema>;
    const result = await authService.refresh(refreshToken);
    reply.status(200).send({ data: result });
  });

  app.post("/auth/logout", async (_request, reply) => {
    reply.status(200).send({ data: { message: "Logged out successfully" } });
  });
}

export async function apiKeyRoutes(app: FastifyInstance): Promise<void> {
  app.get("/api-keys", { preHandler: [requireScope("api_key:read")] }, async (request, reply) => {
    const keys = await authService.listAPIKeys((request as any).organizationId);
    reply.send({ data: keys });
  });

  app.post("/api-keys", { preHandler: [requireScope("api_key:write"), validateBody(createAPIKeySchema)] }, async (request, reply) => {
    const { name, scopes, expiresAt, allowedIPs, environment } = request.body as z.infer<typeof createAPIKeySchema>;
    const result = await authService.createAPIKey((request as any).organizationId, (request as any).user?.id, name, scopes, expiresAt, allowedIPs, environment);
    reply.status(201).send({ data: result });
  });

  app.delete("/api-keys/:id", { preHandler: [requireScope("api_key:write"), validateParams(idParamSchema)] }, async (request, reply) => {
    const { id } = request.params as { id: string };
    await authService.revokeAPIKey((request as any).organizationId, id);
    reply.status(204).send();
  });
}

export async function domainRoutes(app: FastifyInstance): Promise<void> {
  app.get("/domains", { preHandler: [requireScope("domain:read")] }, async (request, reply) => {
    const domains = await domainService.list((request as any).organizationId);
    reply.send({ data: domains });
  });

  app.post("/domains", { preHandler: [requireScope("domain:write")] }, async (request, reply) => {
    const body = request.body as { domain: string };
    const domain = await domainService.create((request as any).organizationId, body.domain);
    reply.status(201).send({ data: domain });
  });

  app.post("/domains/:id/verify", { preHandler: [requireScope("domain:write"), validateParams(idParamSchema)] }, async (request, reply) => {
    const { id } = request.params as { id: string };
    await domainService.get((request as any).organizationId, id);
    await addJob(QUEUE_NAMES.EMAIL_DEFAULT, "verify-domain-dns", { domainId: id, organizationId: (request as any).organizationId });
    reply.send({ data: { message: "Verification started" } });
  });

  app.delete("/domains/:id", { preHandler: [requireScope("domain:write"), validateParams(idParamSchema)] }, async (request, reply) => {
    const { id } = request.params as { id: string };
    await domainService.delete((request as any).organizationId, id);
    reply.status(204).send();
  });
}

export async function templateRoutes(app: FastifyInstance): Promise<void> {
  app.get("/templates", { preHandler: [requireScope("template:read"), validateQuery(paginationSchema)] }, async (request, reply) => {
    const query = request.query as { page: number; perPage: number };
    const result = await templateService.list((request as any).organizationId, query.page, query.perPage);
    reply.send({ data: result.data, meta: { page: result.page, perPage: result.perPage, total: result.total, pages: result.pages } });
  });

  app.post("/templates", { preHandler: [requireScope("template:write")] }, async (request, reply) => {
    const body = request.body as { name: string; subject: string; htmlBody: string; textBody?: string };
    const template = await templateService.create((request as any).organizationId, body);
    reply.status(201).send({ data: template });
  });

  app.post("/templates/:id/send", { preHandler: [requireScope("email:send"), validateParams(idParamSchema)] }, async (request, reply) => {
    const { id } = request.params as { id: string };
    const body = request.body as z.infer<typeof sendTemplateSchema>;
    const environment = (request as any).environment || "live";
    const orgId = (request as any).organizationId;
    await billingService.checkQuota(orgId, 1);
    const result = await emailService.sendFromTemplate(orgId, id, body.to, body.variables, environment);
    await billingService.incrementUsageAndRecordOverage(orgId);
    await addJob(QUEUE_NAMES.EMAIL_CRITICAL, "send-email", { emailMessageId: result.emailId, organizationId: orgId, environment });
    reply.status(202).send({ data: { emailId: result.emailId, environment, message: "Email queued for sending" } });
  });
}

export async function emailRoutes(app: FastifyInstance): Promise<void> {
  app.post("/emails", { preHandler: [requireScope("email:send"), validateBody(sendEmailSchema)] }, async (request, reply) => {
    const body = request.body as z.infer<typeof sendEmailSchema>;
    const scheduledAt = body.scheduledAt ? new Date(body.scheduledAt) : undefined;
    const delay = scheduledAt ? Math.max(0, scheduledAt.getTime() - Date.now()) : undefined;
    const environment = (request as any).environment || "live";
    const toAddresses = Array.isArray(body.to) ? body.to : [body.to];
    const orgId = (request as any).organizationId;
    await billingService.checkQuota(orgId, toAddresses.length);
    if (toAddresses.length === 1) {
      const result = await emailService.send(orgId, body.from, toAddresses[0]!, body.subject, body.html, body.text, body.replyTo, body.tags, body.idempotencyKey, scheduledAt, body.attachmentIds, environment);
      await billingService.incrementUsageAndRecordOverage(orgId);
      await addJob(QUEUE_NAMES.EMAIL_CRITICAL, "send-email", { emailMessageId: result.emailId, organizationId: orgId, environment }, delay ? { delay } : undefined);
      reply.status(202).send({ data: { emailId: result.emailId, environment, scheduledAt: scheduledAt?.toISOString(), message: scheduledAt ? "Email scheduled for sending" : "Email queued for sending" } });
    } else {
      const result = await emailService.sendBatch(orgId, toAddresses.map(to => ({ from: body.from, to, subject: body.subject, html: body.html, text: body.text, replyTo: body.replyTo, tags: body.tags, idempotencyKey: body.idempotencyKey, attachmentIds: body.attachmentIds, environment })), scheduledAt);
      for (const _ of result.emailIds) {
        await billingService.incrementUsageAndRecordOverage(orgId);
      }
      for (const emailId of result.emailIds) {
        await addJob(QUEUE_NAMES.EMAIL_CRITICAL, "send-email", { emailMessageId: emailId, organizationId: orgId, environment }, delay ? { delay } : undefined);
      }
      reply.status(202).send({ data: { batchId: result.batchId, count: result.count, environment, scheduledAt: scheduledAt?.toISOString(), message: scheduledAt ? "Emails scheduled for sending" : "Emails queued for sending" } });
    }
  });

  app.post("/emails/:id/cancel", { preHandler: [requireScope("email:send"), validateParams(idParamSchema)] }, async (request, reply) => {
    const { id } = request.params as { id: string };
    await emailService.cancel((request as any).organizationId, id);
    reply.send({ data: { message: "Email cancelled" } });
  });

  app.get("/emails", { preHandler: [requireScope("email:read"), validateQuery(paginationSchema)] }, async (request, reply) => {
    const query = request.query as { page: number; perPage: number; status?: string; environment?: string; after?: string; limit?: number };
    const result = await emailService.list((request as any).organizationId, { page: query.page, perPage: query.perPage, status: query.status, environment: query.environment, after: query.after, limit: query.limit });
    reply.send({ data: result.data, meta: { page: result.page, perPage: result.perPage, total: result.total, pages: result.pages, nextCursor: result.nextCursor } });
  });

  app.get("/emails/:id", { preHandler: [requireScope("email:read"), validateParams(idParamSchema)] }, async (request, reply) => {
    const { id } = request.params as { id: string };
    const email = await emailService.get((request as any).organizationId, id);
    reply.send({ data: email });
  });

  app.post("/emails/batch", { preHandler: [requireScope("email:send")] }, async (request, reply) => {
    const body = request.body as { messages: z.infer<typeof sendEmailSchema>[] };
    const environment = (request as any).environment || "live";
    const orgId = (request as any).organizationId;
    const messages = body.messages.map(m => ({ ...m, environment }));
    await billingService.checkQuota(orgId, body.messages.length);
    const result = await emailService.sendBatch(orgId, messages);
    for (const _ of result.emailIds) {
      await billingService.incrementUsageAndRecordOverage(orgId);
    }
    for (const emailId of result.emailIds) {
      await addJob(QUEUE_NAMES.EMAIL_CRITICAL, "send-email", { emailMessageId: emailId, organizationId: orgId, environment });
    }
    reply.status(202).send({ data: { batchId: result.batchId, count: result.count, environment, message: "Emails queued for sending" } });
  });

  app.post("/emails/validate", { preHandler: [requireScope("email:send"), validateBody(sendEmailSchema)] }, async (_request, reply) => {
    reply.status(200).send({ data: { valid: true } });
  });
}

export async function attachmentRoutes(app: FastifyInstance): Promise<void> {
  app.post("/attachments", { preHandler: [requireScope("email:send")] }, async (request, reply) => {
    const data = await request.file();
    if (!data) throw new ValidationError("File is required");

    const buffer = await data.toBuffer();
    const maxSize = 25 * 1024 * 1024;
    if (buffer.length > maxSize) throw new ValidationError("File size exceeds 25MB limit");

    const orgId = (request as any).organizationId;
    const result = await storageService.upload(orgId, data.filename, data.mimetype, buffer);

    const attachmentId = crypto.randomUUID();
    await db.insertInto("attachments").values({
      id: attachmentId,
      email_message_id: null,
      filename: data.filename,
      content_type: data.mimetype,
      size_bytes: buffer.length,
      storage_path: result.path,
      storage_provider: "s3",
      checksum: result.checksum,
      created_at: new Date(),
    }).execute();
    reply.status(201).send({ data: { id: attachmentId, filename: data.filename, contentType: data.mimetype, size: buffer.length } });
  });
}

export async function suppressionRoutes(app: FastifyInstance): Promise<void> {
  app.get("/suppressions", { preHandler: [requireScope("email:read"), validateQuery(paginationSchema)] }, async (request, reply) => {
    const query = request.query as { page: number; perPage: number; reason?: string };
    const result = await suppressionService.list((request as any).organizationId, query);
    reply.send({ data: result.data, meta: { page: result.page, perPage: result.perPage, total: result.total, pages: result.pages } });
  });

  app.post("/suppressions", { preHandler: [requireScope("email:send")] }, async (request, reply) => {
    const body = request.body as { email: string; reason?: string };
    const result = await suppressionService.add((request as any).organizationId, body.email, (body.reason as any) || "manual");
    reply.status(201).send({ data: result });
  });

  app.delete("/suppressions/:id", { preHandler: [requireScope("email:send"), validateParams(idParamSchema)] }, async (request, reply) => {
    const { id } = request.params as { id: string };
    await suppressionService.removeById((request as any).organizationId, id);
    reply.status(204).send();
  });
}

export async function analyticsRoutes(app: FastifyInstance): Promise<void> {
  app.get("/analytics/overview", { preHandler: [requireScope("analytics:read")] }, async (request, reply) => {
    const result = await analyticsService.overview((request as any).organizationId);
    reply.send({ data: result });
  });
}

const webhookIdParamSchema = z.object({ id: z.string().uuid() });
const webhookReplayParamSchema = z.object({ id: z.string().uuid(), deliveryId: z.string().uuid() });

export async function webhookRoutes(app: FastifyInstance): Promise<void> {
  app.get("/webhooks", { preHandler: [requireScope("webhook:read")] }, async (request, reply) => {
    const webhooks = await webhookService.list((request as any).organizationId);
    reply.send({ data: webhooks });
  });

  app.post("/webhooks", { preHandler: [requireScope("webhook:write"), validateBody(createWebhookSchema)] }, async (request, reply) => {
    const body = request.body as z.infer<typeof createWebhookSchema>;
    const webhook = await webhookService.create((request as any).organizationId, body);
    reply.status(201).send({ data: webhook });
  });

  app.delete("/webhooks/:id", { preHandler: [requireScope("webhook:write"), validateParams(webhookIdParamSchema)] }, async (request, reply) => {
    const { id } = request.params as { id: string };
    await webhookService.delete((request as any).organizationId, id);
    reply.status(204).send();
  });

  app.post("/webhooks/:id/rotate-secret", { preHandler: [requireScope("webhook:write"), validateParams(webhookIdParamSchema)] }, async (request, reply) => {
    const { id } = request.params as { id: string };
    const result = await webhookService.rotateSecret((request as any).organizationId, id);
    reply.send({ data: result });
  });

  app.get("/webhooks/:id/deliveries", { preHandler: [requireScope("webhook:read"), validateParams(webhookIdParamSchema), validateQuery(paginationSchema)] }, async (request, reply) => {
    const { id } = request.params as { id: string };
    const query = request.query as { page: number; perPage: number };
    const result = await webhookService.getDeliveries((request as any).organizationId, id, query.page, query.perPage);
    reply.send({ data: result.data, meta: result.meta });
  });

  app.post("/webhooks/:id/replay/:deliveryId", { preHandler: [requireScope("webhook:write"), validateParams(webhookReplayParamSchema)] }, async (request, reply) => {
    const { id, deliveryId } = request.params as { id: string; deliveryId: string };
    await webhookService.replay((request as any).organizationId, id, deliveryId);
    reply.send({ data: { message: "Webhook delivery re-queued" } });
  });
}

export async function dashboardRoutes(app: FastifyInstance): Promise<void> {
  app.get("/dashboard/usage", { preHandler: [requireScope("analytics:read")] }, async (request, reply) => {
    const stats = await analyticsService.usage((request as any).organizationId);
    reply.send({ data: stats });
  });

  app.get("/dashboard/providers", { preHandler: [requireScope("analytics:read")] }, async (request, reply) => {
    const providers = await analyticsService.providers((request as any).organizationId);
    reply.send({ data: providers });
  });

  app.get("/dashboard/activity", { preHandler: [requireScope("analytics:read")] }, async (request, reply) => {
    const activity = await analyticsService.activity((request as any).organizationId);
    reply.send({ data: activity });
  });

  app.get("/dashboard/alerts", { preHandler: [requireScope("analytics:read")] }, async (_request, reply) => {
    reply.send({ data: [] });
  });
}

export async function billingRoutes(app: FastifyInstance): Promise<void> {
  app.get("/billing/plans", async (_request, reply) => {
    const plans = await billingService.listPlans();
    reply.send({ data: plans });
  });

  app.get("/billing/subscription", { preHandler: [requireScope("analytics:read")] }, async (request, reply) => {
    const sub = await billingService.getCurrentSubscription((request as any).organizationId);
    const usage = await billingService.getUsage((request as any).organizationId);
    reply.send({ data: { subscription: sub, usage } });
  });

  app.post("/billing/subscription/change", { preHandler: [requireScope("api_key:write")] }, async (request, reply) => {
    const body = request.body as { planSlug: string };
    await billingService.changePlan((request as any).organizationId, body.planSlug);
    reply.send({ data: { message: "Plan changed successfully" } });
  });

  app.post("/billing/overage", { preHandler: [requireScope("api_key:write")] }, async (request, reply) => {
    const body = request.body as { enabled: boolean };
    await billingService.enableOverage((request as any).organizationId, body.enabled);
    reply.send({ data: { message: body.enabled ? "Overage enabled" : "Overage disabled" } });
  });

  app.post("/billing/invoices/generate-overage", { preHandler: [requireScope("api_key:write")] }, async (request, reply) => {
    const result = await billingService.generateOverageInvoice((request as any).organizationId);
    reply.send({ data: result });
  });

  app.get("/billing/invoices", { preHandler: [requireScope("analytics:read"), validateQuery(paginationSchema)] }, async (request, reply) => {
    const query = request.query as { page: number; perPage: number };
    const result = await billingService.listInvoices((request as any).organizationId, query.page, query.perPage);
    reply.send({ data: result.data, meta: result.meta });
  });

  app.post("/billing/invoices/:id/pay", { preHandler: [requireScope("api_key:write"), validateParams(idParamSchema)] }, async (request, reply) => {
    const { id } = request.params as { id: string };
    const result = await billingService.initializePaystackPayment(id, (request as any).organizationId);
    reply.send({ data: result });
  });

  await app.register(async function paystackWebhook(instance) {
    const defaultJsonParser = instance.getDefaultJsonParser("error", "error");
    instance.addContentTypeParser("application/json", { parseAs: "string" }, (request, body, done) => {
      (request as any).rawBody = String(body);
      defaultJsonParser(request, String(body), done);
    });

    instance.post("/billing/webhook/paystack", async (request, reply) => {
      const signature = request.headers["x-paystack-signature"];
      const rawBody = (request as any).rawBody;
      const secret = env.PAYSTACK_SECRET_KEY;

      if (typeof signature !== "string" || typeof rawBody !== "string" || !secret || !verifyWebhookSignature(rawBody, secret, signature, "sha512")) {
        throw new UnauthorizedError("Invalid Paystack signature");
      }

      await billingService.handlePaystackWebhook(request.body);
      reply.status(200).send({ status: "ok" });
    });
  });
}

export async function auditRoutes(app: FastifyInstance): Promise<void> {
  app.get("/audit-logs", { preHandler: [requireScope("analytics:read"), validateQuery(paginationSchema)] }, async (request, reply) => {
    const query = request.query as { page: number; perPage: number };
    const result = await auditService.list((request as any).organizationId, query.page, query.perPage);
    reply.send({ data: result.data, meta: result.meta });
  });
}

export async function registerRoutes(app: FastifyInstance): Promise<void> {
  await authRoutes(app);
  await apiKeyRoutes(app);
  await domainRoutes(app);
  await templateRoutes(app);
  await emailRoutes(app);
  await analyticsRoutes(app);
  await webhookRoutes(app);
  await attachmentRoutes(app);
  await suppressionRoutes(app);
  await dashboardRoutes(app);
  await billingRoutes(app);
  await auditRoutes(app);
}
