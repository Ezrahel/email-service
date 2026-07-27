import type { FastifyInstance } from "fastify";
import { z } from "zod";
import { AuthService, EmailService, DomainService, TemplateService, WebhookService, AnalyticsService } from "@email-service/domain";
import { ValidationError, NotFoundError } from "@email-service/errors";
import { requireScope } from "../middleware/auth.js";
import { validateBody, validateQuery, validateParams, paginationSchema, idParamSchema } from "../middleware/validation.js";
import { addJob, QUEUE_NAMES } from "@email-service/queue";

const authService = new AuthService();
const emailService = new EmailService();
const domainService = new DomainService();
const templateService = new TemplateService();
const webhookService = new WebhookService();
const analyticsService = new AnalyticsService();

const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8).max(128),
});
const refreshSchema = z.object({
  refreshToken: z.string().min(10),
});
const createAPIKeySchema = z.object({
  name: z.string().min(1).max(255),
  scopes: z.array(z.string()).default(["email:send", "email:read", "template:manage", "webhook:manage", "api_key:manage", "analytics:read"]),
  expiresAt: z.string().datetime().optional(),
  allowedIPs: z.array(z.string().regex(/^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9])\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9])$/)).optional(),
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
    const { name, scopes, expiresAt, allowedIPs } = request.body as z.infer<typeof createAPIKeySchema>;
    const result = await authService.createAPIKey((request as any).organizationId, (request as any).user?.id, name, scopes, expiresAt, allowedIPs);
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
    const result = await emailService.sendFromTemplate((request as any).organizationId, id, body.to, body.variables);
    await addJob(QUEUE_NAMES.EMAIL_CRITICAL, "send-email", { emailMessageId: result.emailId, organizationId: (request as any).organizationId });
    reply.status(202).send({ data: { emailId: result.emailId, message: "Email queued for sending" } });
  });
}

export async function emailRoutes(app: FastifyInstance): Promise<void> {
  app.post("/emails", { preHandler: [requireScope("email:send"), validateBody(sendEmailSchema)] }, async (request, reply) => {
    const body = request.body as z.infer<typeof sendEmailSchema>;
    const toAddresses = Array.isArray(body.to) ? body.to : [body.to];
    if (toAddresses.length === 1) {
      const result = await emailService.send((request as any).organizationId, body.from, toAddresses[0]!, body.subject, body.html, body.text, body.replyTo, body.tags, body.idempotencyKey);
      await addJob(QUEUE_NAMES.EMAIL_CRITICAL, "send-email", { emailMessageId: result.emailId, organizationId: (request as any).organizationId });
      reply.status(202).send({ data: { emailId: result.emailId, message: "Email queued for sending" } });
    } else {
      const result = await emailService.sendBatch((request as any).organizationId, toAddresses.map(to => ({ from: body.from, to, subject: body.subject, html: body.html, text: body.text, replyTo: body.replyTo, tags: body.tags, idempotencyKey: body.idempotencyKey })));
      for (const emailId of result.emailIds) {
        await addJob(QUEUE_NAMES.EMAIL_CRITICAL, "send-email", { emailMessageId: emailId, organizationId: (request as any).organizationId });
      }
      reply.status(202).send({ data: { batchId: result.batchId, count: result.count, message: "Emails queued for sending" } });
    }
  });

  app.get("/emails", { preHandler: [requireScope("email:read"), validateQuery(paginationSchema)] }, async (request, reply) => {
    const query = request.query as { page: number; perPage: number; status?: string };
    const result = await emailService.list((request as any).organizationId, { page: query.page, perPage: query.perPage, status: query.status });
    reply.send({ data: result.data, meta: { page: result.page, perPage: result.perPage, total: result.total, pages: result.pages } });
  });

  app.get("/emails/:id", { preHandler: [requireScope("email:read"), validateParams(idParamSchema)] }, async (request, reply) => {
    const { id } = request.params as { id: string };
    const email = await emailService.get((request as any).organizationId, id);
    reply.send({ data: email });
  });

  app.post("/emails/batch", { preHandler: [requireScope("email:send")] }, async (request, reply) => {
    const body = request.body as { messages: z.infer<typeof sendEmailSchema>[] };
    const result = await emailService.sendBatch((request as any).organizationId, body.messages);
    for (const emailId of result.emailIds) {
      await addJob(QUEUE_NAMES.EMAIL_CRITICAL, "send-email", { emailMessageId: emailId, organizationId: (request as any).organizationId });
    }
    reply.status(202).send({ data: { batchId: result.batchId, count: result.count, message: "Emails queued for sending" } });
  });

  app.post("/emails/validate", { preHandler: [requireScope("email:send"), validateBody(sendEmailSchema)] }, async (_request, reply) => {
    reply.status(200).send({ data: { valid: true } });
  });
}

export async function analyticsRoutes(app: FastifyInstance): Promise<void> {
  app.get("/analytics/overview", { preHandler: [requireScope("analytics:read")] }, async (request, reply) => {
    const result = await analyticsService.overview((request as any).organizationId);
    reply.send({ data: result });
  });
}

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

  app.delete("/webhooks/:id", { preHandler: [requireScope("webhook:write"), validateParams(idParamSchema)] }, async (request, reply) => {
    const { id } = request.params as { id: string };
    await webhookService.delete((request as any).organizationId, id);
    reply.status(204).send();
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

export async function registerRoutes(app: FastifyInstance): Promise<void> {
  await authRoutes(app);
  await apiKeyRoutes(app);
  await domainRoutes(app);
  await templateRoutes(app);
  await emailRoutes(app);
  await analyticsRoutes(app);
  await webhookRoutes(app);
  await dashboardRoutes(app);
}
