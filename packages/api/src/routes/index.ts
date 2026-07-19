import type { FastifyInstance } from "fastify";
import { sql } from "kysely";
import crypto from "crypto";
import { z } from "zod";
import { db } from "@email-service/database";
import { logger } from "@email-service/logger";
import { ValidationError, NotFoundError, UnauthorizedError, ForbiddenError, ConflictError } from "@email-service/errors";
import { generateAccessToken, generateRefreshToken, verifyAccessToken, verifyRefreshToken, verifyPassword, hashPassword, generateAPIKey } from "@email-service/crypto";
import { requireScope, requireOrganizationAccess } from "../middleware/auth.js";
import { validateBody, validateQuery, validateParams, paginationSchema, idParamSchema } from "../middleware/validation.js";
import { addJob, QUEUE_NAMES } from "@email-service/queue";

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
  allowedIPs: z.array(z.string()).optional(),
});

const ipRegex = /^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9])\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9])$/;

const createAPIKeySchemaWithIP = z.object({
  name: z.string().min(1).max(255),
  scopes: z.array(z.string()).default(["email:send", "email:read", "template:manage", "webhook:manage", "api_key:manage", "analytics:read"]),
  expiresAt: z.string().datetime().optional(),
  allowedIPs: z.array(z.string().regex(ipRegex)).optional(),
});

function renderTemplate(template: string, variables: Record<string, string>): string {
  return template.replace(/\{\{(\w+)\}\}/g, (match, key) => variables[key] ?? match);
}

export async function authRoutes(app: FastifyInstance): Promise<void> {
  app.post(
    "/auth/login",
    { preHandler: [validateBody(loginSchema)] },
    async (request, reply) => {
      const { email, password } = request.body as { email: string; password: string };

      const user = await db
        .selectFrom("users")
        .selectAll()
        .where("email", "=", email)
        .where("status", "=", "active")
        .executeTakeFirst();

      if (!user || !(await verifyPassword(password, user.password_hash))) {
        logger.warn({ email }, "Failed login attempt");
        throw new UnauthorizedError("Invalid email or password");
      }

      if (user.status === "locked") {
        throw new ForbiddenError("Account locked. Try again later.");
      }

      const { token, expiresAt } = await generateAccessToken(user.id, user.email);
      const { token: refreshToken, expiresAt: refreshExpiresAt } = await generateRefreshToken(user.id);

      const membership = await db
        .selectFrom("memberships")
        .select(["organization_id", "role_id"])
        .where("user_id", "=", user.id)
        .where("status", "=", "active")
        .executeTakeFirst();

      reply.status(200).send({
        data: {
          token,
          refreshToken,
          expiresAt,
          user: {
            id: user.id,
            email: user.email,
            firstName: user.first_name,
            lastName: user.last_name,
            organizationId: membership?.organization_id,
          },
        },
      });
    }
  );

  app.post(
    "/auth/refresh",
    { preHandler: [validateBody(refreshSchema)] },
    async (request, reply) => {
      const { refreshToken } = request.body as { refreshToken: string };

      const payload = await verifyRefreshToken(refreshToken);
      if (!payload) {
        throw new UnauthorizedError("Invalid or expired refresh token");
      }

      const { token, expiresAt } = await generateAccessToken(payload.sub, payload.email || "");
      const { token: newRefreshToken, expiresAt: refreshExpiresAt } = await generateRefreshToken(payload.sub);

      reply.status(200).send({
        data: {
          token,
          refreshToken: newRefreshToken,
          expiresAt,
        },
      });
    }
  );

  app.post("/auth/logout", async (request, reply) => {
    reply.status(200).send({ data: { message: "Logged out successfully" } });
  });
}

export async function apiKeyRoutes(app: FastifyInstance): Promise<void> {
  const createAPIKeySchema = z.object({
    name: z.string().min(1).max(255),
    scopes: z.array(z.string()).default(["email:send", "email:read", "template:manage", "webhook:manage", "api_key:manage", "analytics:read"]),
    expiresAt: z.string().datetime().optional(),
    allowedIPs: z.array(z.string().regex(/^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9])\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9])$/)).optional(),
  });

  const idParamSchema = z.object({
    id: z.string().uuid(),
  });

  app.get(
    "/api-keys",
    { preHandler: [requireScope("api_key:read")] },
    async (request, reply) => {
      const apiKey = (request as any).apiKey;
      const keys = await db
        .selectFrom("api_keys")
        .select(["id", "name", "key_prefix", "key_last_chars", "scopes", "status", "expires_at", "last_used_at", "created_at"])
        .where("organization_id", "=", apiKey.organizationId)
        .where("deleted_at", "is", null)
        .orderBy("created_at", "desc")
        .execute();

      reply.send({ data: keys });
    }
  );

  app.post(
    "/api-keys",
    { preHandler: [requireScope("api_key:write"), validateBody(createAPIKeySchema)] },
    async (request, reply) => {
      const apiKey = (request as any).apiKey;
      const { name, scopes, expiresAt, allowedIPs } = request.body as {
        name: string;
        scopes: string[];
        expiresAt?: string;
        allowedIPs?: string[];
      };

      const { prefix, fullKey, digest, lastChars } = await generateAPIKey();

      await db
        .insertInto("api_keys")
        .values({
          id: crypto.randomUUID(),
          organization_id: apiKey.organizationId,
          user_id: (request as any).user?.id ?? null,
          name,
          key_prefix: prefix,
          key_digest: digest,
          key_last_chars: lastChars,
          scopes,
          allowed_ips: allowedIPs || [],
          status: "active",
          expires_at: expiresAt ? new Date(expiresAt) : null,
          created_at: new Date(),
          updated_at: new Date(),
        })
        .execute();

      reply.status(201).send({
        data: {
          key: fullKey,
          name,
          scopes,
          expiresAt: expiresAt ?? null,
        },
      });
    }
  );

  app.delete(
    "/api-keys/:id",
    { preHandler: [requireScope("api_key:write"), validateParams(idParamSchema)] },
    async (request, reply) => {
      const apiKey = (request as any).apiKey;
      const { id } = request.params as { id: string };

      await db
        .updateTable("api_keys")
        .set({ status: "revoked", revoked_at: new Date() })
        .where("id", "=", id)
        .where("organization_id", "=", apiKey.organizationId)
        .execute();

      reply.status(204).send();
    }
  );
}

export async function domainRoutes(app: FastifyInstance): Promise<void> {
  app.get(
    "/domains",
    { preHandler: [requireScope("domain:read")] },
    async (request, reply) => {
      const apiKey = (request as any).apiKey;
      const domains = await db
        .selectFrom("domains")
        .selectAll()
        .where("organization_id", "=", apiKey.organizationId)
        .where("deleted_at", "is", null)
        .orderBy("created_at", "desc")
        .execute();

      reply.send({ data: domains });
    }
  );

  app.post(
    "/domains",
    { preHandler: [requireScope("domain:write")] },
    async (request, reply) => {
      const apiKey = (request as any).apiKey;
      const body = request.body as { domain: string };

      const domainRegex = /^(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z]{2,}$/i;
      if (!domainRegex.test(body.domain)) {
        throw new ValidationError("Invalid domain format");
      }

      const existing = await db
        .selectFrom("domains")
        .select("id")
        .where("domain", "=", body.domain.toLowerCase())
        .where("organization_id", "=", apiKey.organizationId)
        .executeTakeFirst();

      if (existing) {
        throw new ConflictError("Domain already exists");
      }

      const domain = await db
        .insertInto("domains")
        .values({
          id: crypto.randomUUID(),
          organization_id: apiKey.organizationId,
          domain: body.domain.toLowerCase(),
          status: "pending",
          dkim_selector: "mailo",
          dkim_private_key_ciphertext: null,
          dkim_public_key: null,
          dkim_verified: false,
          spf_verified: false,
          dmarc_verified: false,
          tracking_enabled: false,
          created_at: new Date(),
          updated_at: new Date(),
        })
        .returningAll()
        .executeTakeFirstOrThrow();

      reply.status(201).send({ data: domain });
    }
  );

  app.post(
    "/domains/:id/verify",
    { preHandler: [requireScope("domain:write"), validateParams(idParamSchema)] },
    async (request, reply) => {
      const { id } = request.params as { id: string };
      const apiKey = (request as any).apiKey;

      const domain = await db
        .selectFrom("domains")
        .selectAll()
        .where("id", "=", id)
        .where("organization_id", "=", apiKey.organizationId)
        .executeTakeFirst();

      if (!domain) {
        throw new NotFoundError("Domain");
      }

      await addJob(QUEUE_NAMES.EMAIL_DEFAULT, "verify-domain-dns", {
        domainId: id,
        organizationId: apiKey.organizationId,
      });

      reply.send({ data: { message: "Verification started" } });
    }
  );
}

export async function templateRoutes(app: FastifyInstance): Promise<void> {
  app.get(
    "/templates",
    { preHandler: [requireScope("template:read"), validateQuery(paginationSchema)] },
    async (request, reply) => {
      const apiKey = (request as any).apiKey;
      const query = request.query as { page: number; perPage: number };

      const [templates, total] = await Promise.all([
        db
          .selectFrom("templates")
          .selectAll()
          .where("organization_id", "=", apiKey.organizationId)
          .where("deleted_at", "is", null)
          .orderBy("created_at", "desc")
          .limit(query.perPage)
          .offset((query.page - 1) * query.perPage)
          .execute(),
        db
          .selectFrom("templates")
          .select((eb) => eb.fn.count("id").as("count"))
          .where("organization_id", "=", apiKey.organizationId)
          .where("deleted_at", "is", null)
          .executeTakeFirstOrThrow(),
      ]);

      reply.send({
        data: templates,
        meta: { page: query.page, perPage: query.perPage, total: Number(total.count), pages: Math.ceil(Number(total.count) / query.perPage) },
      });
    }
  );

  app.post(
    "/templates",
    { preHandler: [requireScope("template:write")] },
    async (request, reply) => {
      const apiKey = (request as any).apiKey;
      const body = request.body as { name: string; subject: string; htmlBody: string; textBody?: string };

      const template = await db
        .insertInto("templates")
        .values({
          id: crypto.randomUUID(),
          organization_id: apiKey.organizationId,
          name: body.name,
          slug: body.name.toLowerCase().replace(/\s+/g, "-"),
          current_version_id: null,
          created_at: new Date(),
          updated_at: new Date(),
        })
        .returningAll()
        .executeTakeFirstOrThrow();

      await db
        .insertInto("template_versions")
        .values({
          id: crypto.randomUUID(),
          template_id: template.id,
          version: 1,
          subject: body.subject,
          html_body: body.htmlBody,
          text_body: body.textBody || null,
          variables: {},
          is_published: false,
          created_at: new Date(),
        })
        .execute();

      reply.status(201).send({ data: template });
    }
  );

  app.post(
    "/templates/:id/send",
    { preHandler: [requireScope("email:send"), validateParams(idParamSchema)] },
    async (request, reply) => {
      const { id } = request.params as { id: string };
      const apiKey = (request as any).apiKey;
      const body = request.body as { to: string; variables?: Record<string, string> };

      const template = await db
        .selectFrom("templates")
        .innerJoin("template_versions", "template_versions.template_id", "templates.id")
        .select(["templates.id", "template_versions.subject", "template_versions.html_body", "template_versions.text_body"])
        .where("templates.id", "=", id)
        .where("templates.organization_id", "=", apiKey.organizationId)
        .where("template_versions.is_published", "=", true)
        .where("template_versions.version", "=", (eb) =>
          eb.selectFrom("template_versions").select((eb) => eb.fn.max("version").as("max_version")).where("template_id", "=", id)
        )
        .executeTakeFirst();

      if (!template) {
        throw new NotFoundError("Template");
      }

      const htmlBody = renderTemplate(template.html_body, body.variables || {});
      const textBody = template.text_body ? renderTemplate(template.text_body, body.variables || {}) : null;

      const emailId = crypto.randomUUID();
      await db
        .insertInto("email_messages")
        .values({
          id: emailId,
          organization_id: apiKey.organizationId,
          batch_id: crypto.randomUUID(),
          template_id: id,
          from_address: `noreply@${(await db.selectFrom("domains").select("domain").where("organization_id", "=", apiKey.organizationId).executeTakeFirst())?.domain || "example.com"}`,
          to_address: body.to,
          recipient_type: "to",
          subject: renderTemplate(template.subject, body.variables || {}),
          html_body: htmlBody,
          text_body: textBody,
          headers: {},
          tags: [],
          status: "queued",
          idempotency_key: null,
          reply_to: null,
          created_at: new Date(),
          updated_at: new Date(),
          retry_count: 0,
          max_retries: 3,
        })
        .execute();

      await addJob(QUEUE_NAMES.EMAIL_CRITICAL, "send-email", {
        emailMessageId: emailId,
        organizationId: apiKey.organizationId,
      });

      reply.status(202).send({ data: { emailId, message: "Email queued for sending" } });
    }
  );
}

export async function emailRoutes(app: FastifyInstance): Promise<void> {
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

  app.post(
    "/emails",
    { preHandler: [requireScope("email:send"), validateBody(sendEmailSchema)] },
    async (request, reply) => {
      const apiKey = (request as any).apiKey;
      const body = request.body as z.infer<typeof sendEmailSchema>;

      if (body.idempotencyKey) {
        const existing = await db
          .selectFrom("email_messages")
          .select("id")
          .where("idempotency_key", "=", body.idempotencyKey)
          .where("organization_id", "=", apiKey.organizationId)
          .executeTakeFirst();

        if (existing) {
          reply.status(200).send({ data: { id: existing.id, message: "Email already sent" } });
          return;
        }
      }

      const emailId = crypto.randomUUID();
      const batchId = crypto.randomUUID();

      const toAddresses = Array.isArray(body.to) ? body.to : [body.to];

      await db
        .insertInto("email_messages")
        .values(
          toAddresses.map((to) => ({
            id: crypto.randomUUID(),
            organization_id: apiKey.organizationId,
            batch_id: batchId,
            from_address: body.from,
            to_address: to,
            recipient_type: "to",
            subject: body.subject,
            html_body: body.html,
            text_body: body.text,
            headers: {},
            tags: body.tags || [],
            status: "queued" as const,
            idempotency_key: body.idempotencyKey,
            reply_to: body.replyTo,
            created_at: new Date(),
            updated_at: new Date(),
            retry_count: 0,
            max_retries: 3,
          })))
        .execute();

      for (let i = 0; i < toAddresses.length; i++) {
        await addJob(QUEUE_NAMES.EMAIL_CRITICAL, "send-email", {
          emailMessageId: crypto.randomUUID(),
          organizationId: apiKey.organizationId,
        });
      }

      reply.status(202).send({ data: { batchId, count: toAddresses.length, message: "Emails queued for sending" } });
    }
  );

  app.get(
    "/emails",
    { preHandler: [requireScope("email:read"), validateQuery(paginationSchema)] },
    async (request, reply) => {
      const apiKey = (request as any).apiKey;
      const query = request.query as { page: number; perPage: number; status?: string };

      let baseQuery = db
        .selectFrom("email_messages")
        .selectAll()
        .where("organization_id", "=", apiKey.organizationId)
        .where("deleted_at", "is", null)
        .orderBy("created_at", "desc");

      if (query.status) {
        baseQuery = baseQuery.where("status", "=", query.status);
      }

      const [emails, total] = await Promise.all([
        baseQuery.limit(query.perPage).offset((query.page - 1) * query.perPage).execute(),
        db
          .selectFrom("email_messages")
          .select((eb) => eb.fn.count("id").as("count"))
          .where("organization_id", "=", apiKey.organizationId)
          .where("deleted_at", "is", null)
          .executeTakeFirstOrThrow(),
      ]);

      reply.send({
        data: emails,
        meta: { page: query.page, perPage: query.perPage, total: Number(total.count), pages: Math.ceil(Number(total.count) / query.perPage) },
      });
    }
  );

  app.get(
    "/emails/:id",
    { preHandler: [requireScope("email:read"), validateParams(idParamSchema)] },
    async (request, reply) => {
      const { id } = request.params as { id: string };
      const apiKey = (request as any).apiKey;

      const email = await db
        .selectFrom("email_messages")
        .selectAll()
        .where("id", "=", id)
        .where("organization_id", "=", apiKey.organizationId)
        .executeTakeFirst();

      if (!email) {
        throw new NotFoundError("Email");
      }

      const deliveries = await db
        .selectFrom("deliveries")
        .selectAll()
        .where("email_message_id", "=", id)
        .execute();

      reply.send({ data: { ...email, deliveries } });
    }
  );

  app.post(
    "/emails/batch",
    { preHandler: [requireScope("email:send")] },
    async (request, reply) => {
      const apiKey = (request as any).apiKey;
      const body = request.body as { messages: z.infer<typeof sendEmailSchema>[] };

      if (body.messages.length > 1000) {
        throw new ValidationError("Batch limit is 1000 messages");
      }

      const batchId = crypto.randomUUID();
      const emailIds: string[] = [];

      for (const msg of body.messages) {
        const emailId = crypto.randomUUID();

        const toAddress = Array.isArray(msg.to) ? msg.to.join(", ") : msg.to;
        await db.insertInto("email_messages").values({
          id: crypto.randomUUID(),
          organization_id: apiKey.organizationId,
          batch_id: batchId,
          from_address: msg.from,
          to_address: toAddress,
          recipient_type: "to",
          subject: msg.subject,
          html_body: msg.html,
          text_body: msg.text,
          headers: {},
          tags: msg.tags || [],
          status: "queued" as const,
          idempotency_key: msg.idempotencyKey,
          reply_to: msg.replyTo,
          created_at: new Date(),
          updated_at: new Date(),
          retry_count: 0,
          max_retries: 3,
        }).execute();

        await addJob(QUEUE_NAMES.EMAIL_CRITICAL, "send-email", {
          emailMessageId: crypto.randomUUID(),
          organizationId: apiKey.organizationId,
        });
      }

      reply.status(202).send({ data: { batchId, count: body.messages.length, message: "Emails queued for sending" } });
    }
  );

  app.post(
    "/emails/validate",
    { preHandler: [requireScope("email:send"), validateBody(sendEmailSchema)] },
    async (request, reply) => {
      reply.status(200).send({ data: { valid: true } });
    }
  );
}

export async function analyticsRoutes(app: FastifyInstance): Promise<void> {
  app.get(
    "/analytics/overview",
    { preHandler: [requireScope("analytics:read")] },
    async (request, reply) => {
      const apiKey = (request as any).apiKey;

      const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);

      const [sent, delivered, bounced, complained, opened, clicked] = await Promise.all([
        db
          .selectFrom("email_messages")
          .select((eb) => eb.fn.count("id").as("count"))
          .where("organization_id", "=", apiKey.organizationId)
          .where("created_at", ">=", thirtyDaysAgo)
          .executeTakeFirstOrThrow(),
        db
          .selectFrom("deliveries")
          .innerJoin("email_messages", "email_messages.id", "deliveries.email_message_id")
          .select((eb) => eb.fn.count("deliveries.id").as("count"))
          .where("email_messages.organization_id", "=", apiKey.organizationId)
          .where("deliveries.status", "=", "delivered")
          .where("deliveries.delivered_at", ">=", thirtyDaysAgo)
          .executeTakeFirstOrThrow(),
        db
          .selectFrom("deliveries")
          .innerJoin("email_messages", "email_messages.id", "deliveries.email_message_id")
          .select((eb) => eb.fn.count("deliveries.id").as("count"))
          .where("email_messages.organization_id", "=", apiKey.organizationId)
          .where("deliveries.status", "=", "bounced")
          .where("deliveries.created_at", ">=", thirtyDaysAgo)
          .executeTakeFirstOrThrow(),
        db
          .selectFrom("email_metrics")
          .innerJoin("email_messages", "email_messages.id", "email_metrics.email_message_id")
          .select((eb) => eb.fn.count("email_metrics.id").as("count"))
          .where("email_messages.organization_id", "=", apiKey.organizationId)
          .where("email_metrics.is_complained", "=", true)
          .where("email_metrics.created_at", ">=", thirtyDaysAgo)
          .executeTakeFirstOrThrow(),
        db
          .selectFrom("email_metrics")
          .innerJoin("email_messages", "email_messages.id", "email_metrics.email_message_id")
          .select((eb) => eb.fn.count("email_metrics.id").as("count"))
          .where("email_messages.organization_id", "=", apiKey.organizationId)
          .where("email_metrics.is_opened", "=", true)
          .where("email_metrics.created_at", ">=", thirtyDaysAgo)
          .executeTakeFirstOrThrow(),
        db
          .selectFrom("email_metrics")
          .innerJoin("email_messages", "email_messages.id", "email_metrics.email_message_id")
          .select((eb) => eb.fn.count("email_metrics.id").as("count"))
          .where("email_messages.organization_id", "=", apiKey.organizationId)
          .where("email_metrics.is_clicked", "=", true)
          .where("email_metrics.created_at", ">=", thirtyDaysAgo)
          .executeTakeFirstOrThrow(),
      ]);

      const sentCount = Number(sent.count);
      const deliveredCount = Number(delivered.count);

      reply.send({
        data: {
          period: "30d",
          sent: sentCount,
          delivered: deliveredCount,
          bounced: Number(bounced.count),
          complained: Number(complained.count),
          opened: Number(opened.count),
          clicked: Number(clicked.count),
          deliveryRate: sentCount > 0 ? (deliveredCount / sentCount) * 100 : 0,
          bounceRate: sentCount > 0 ? (Number(bounced.count) / sentCount) * 100 : 0,
          openRate: deliveredCount > 0 ? (Number(opened.count) / deliveredCount) * 100 : 0,
          clickRate: deliveredCount > 0 ? (Number(clicked.count) / deliveredCount) * 100 : 0,
        },
      });
    }
  );
}

export async function webhookRoutes(app: FastifyInstance): Promise<void> {
  app.get(
    "/webhooks",
    { preHandler: [requireScope("webhook:read")] },
    async (request, reply) => {
      const apiKey = (request as any).apiKey;
      const webhooks = await db
        .selectFrom("webhooks")
        .selectAll()
        .where("organization_id", "=", apiKey.organizationId)
        .where("deleted_at", "is", null)
        .orderBy("created_at", "desc")
        .execute();

      reply.send({ data: webhooks });
    }
  );

  const createWebhookSchema = z.object({
    url: z.string().url(),
    events: z.array(z.string()).min(1),
    secret: z.string().optional(),
  });

  app.post(
    "/webhooks",
    { preHandler: [requireScope("webhook:write"), validateBody(createWebhookSchema)] },
    async (request, reply) => {
      const apiKey = (request as any).apiKey;
      const body = request.body as { url: string; events: string[]; secret?: string };

      const webhook = await db
        .insertInto("webhooks")
        .values({
          id: crypto.randomUUID(),
          organization_id: apiKey.organizationId,
          url: body.url,
          events: body.events,
          secret_ciphertext: body.secret ? "encrypted_" + body.secret : "",
          status: "active" as const,
          failure_count: 0,
          created_at: new Date(),
          updated_at: new Date(),
        })
        .returningAll()
        .executeTakeFirstOrThrow();

      reply.status(201).send({ data: webhook });
    }
  );

  app.delete(
    "/webhooks/:id",
    { preHandler: [requireScope("webhook:write"), validateParams(idParamSchema)] },
    async (request, reply) => {
      const { id } = request.params as { id: string };
      const apiKey = (request as any).apiKey;

      await db
        .updateTable("webhooks")
        .set({ status: "deleted", deleted_at: new Date() })
        .where("id", "=", id)
        .where("organization_id", "=", apiKey.organizationId)
        .execute();

      reply.status(204).send();
    }
  );
}

export async function dashboardRoutes(app: FastifyInstance): Promise<void> {
  app.get(
    "/dashboard/usage",
    { preHandler: [requireScope("analytics:read")] },
    async (request, reply) => {
      const apiKey = (request as any).apiKey;
      const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);

      const stats = await db
        .selectFrom("email_messages")
        .select([
          (eb) => eb.fn.count("id").as("total_sent"),
          sql<number>`COUNT(CASE WHEN status = 'delivered' THEN 1 END)`.as("delivered"),
          sql<number>`COUNT(CASE WHEN status = 'bounced' THEN 1 END)`.as("bounced"),
          sql<number>`COUNT(CASE WHEN status = 'opened' THEN 1 END)`.as("opened"),
          sql<number>`COUNT(CASE WHEN status = 'clicked' THEN 1 END)`.as("clicked"),
        ])
        .where("organization_id", "=", apiKey.organizationId)
        .where("created_at", ">=", thirtyDaysAgo)
        .executeTakeFirstOrThrow();

      reply.send({ data: stats });
    }
  );

  app.get(
    "/dashboard/providers",
    { preHandler: [requireScope("analytics:read")] },
    async (request, reply) => {
      const apiKey = (request as any).apiKey;
      const providers = await db
        .selectFrom("deliveries")
        .innerJoin("email_messages", "email_messages.id", "deliveries.email_message_id")
        .select([
          "deliveries.provider_type",
          (eb) => eb.fn.count("deliveries.id").as("count"),
          sql<number>`COUNT(CASE WHEN deliveries.status = 'delivered' THEN 1 END)`.as("delivered"),
          sql<number>`COUNT(CASE WHEN deliveries.status = 'bounced' THEN 1 END)`.as("bounced"),
        ])
        .where("email_messages.organization_id", "=", apiKey.organizationId)
        .groupBy("deliveries.provider_type")
        .execute();

      reply.send({ data: providers });
    }
  );

  app.get(
    "/dashboard/activity",
    { preHandler: [requireScope("analytics:read")] },
    async (request, reply) => {
      const apiKey = (request as any).apiKey;
      const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);

      const activity = await db
        .selectFrom("email_messages")
        .select([
          "created_at",
          (eb) => eb.fn.count("id").as("count"),
        ])
        .where("organization_id", "=", apiKey.organizationId)
        .where("created_at", ">=", thirtyDaysAgo)
        .groupBy("created_at")
        .orderBy("created_at", "asc")
        .execute();

      reply.send({ data: activity });
    }
  );

  app.get(
    "/dashboard/alerts",
    { preHandler: [requireScope("analytics:read")] },
    async (request, reply) => {
      const apiKey = (request as any).apiKey;
      reply.send({ data: [] });
    }
  );
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