import { db, sql } from "@resendbyte/database";
import { ValidationError, NotFoundError } from "@resendbyte/errors";
import crypto from "node:crypto";

export interface SendEmailInput {
  from: string; to: string | string[]; subject: string;
  html?: string; text?: string; replyTo?: string;
  tags?: string[]; idempotencyKey?: string;
  attachmentIds?: string[];
  environment?: string;
}

export interface SendFromTemplateInput {
  templateId: string; to: string; variables?: Record<string, string>;
}

export interface EmailResult {
  emailId: string; status: string;
}

function renderTemplate(template: string, variables: Record<string, string>): string {
  return template.replace(/\{\{(\w+)\}\}/g, (_, key: string) => variables[key] ?? `{{${key}}}`);
}

export class EmailService {
  async send(organizationId: string, from: string, to: string, subject: string, html?: string, text?: string, replyTo?: string, tags?: string[], idempotencyKey?: string, scheduledAt?: Date, attachmentIds?: string[], environment?: string): Promise<EmailResult> {
    const emailId = crypto.randomUUID();
    const now = new Date();
    await db.insertInto("email_messages").values({
      id: emailId, organization_id: organizationId, batch_id: crypto.randomUUID(),
      from_address: from, to_address: to, recipient_type: "to",
      subject, html_body: html || null, text_body: text || null,
      headers: {}, tags: tags || [],
      status: scheduledAt && scheduledAt > now ? "scheduled" : "queued",
      idempotency_key: idempotencyKey || null,
      reply_to: replyTo || null,
      scheduled_at: scheduledAt || null,
      environment: environment || "live",
      created_at: now, updated_at: now,
      retry_count: 0, max_retries: 3,
    }).execute();

    if (attachmentIds && attachmentIds.length > 0) {
      await db.updateTable("attachments").set({ email_message_id: emailId }).where("id", "in", attachmentIds).execute();
    }

    return { emailId, status: scheduledAt && scheduledAt > now ? "scheduled" : "queued" };
  }

  async sendBatch(organizationId: string, messages: SendEmailInput[], scheduledAt?: Date): Promise<{ batchId: string; emailIds: string[]; count: number }> {
    if (messages.length > 1000) throw new ValidationError("Batch limit is 1000 messages");
    const batchId = crypto.randomUUID();
    const now = new Date();
    const status = scheduledAt && scheduledAt > now ? "scheduled" : "queued";
    const emailIds: string[] = [];
    for (const msg of messages) {
      const emailId = crypto.randomUUID();
      emailIds.push(emailId);
      const toAddress = Array.isArray(msg.to) ? msg.to.join(", ") : msg.to;
      await db.insertInto("email_messages").values({
        id: emailId, organization_id: organizationId, batch_id: batchId,
        from_address: msg.from, to_address: toAddress, recipient_type: "to",
        subject: msg.subject, html_body: msg.html || null, text_body: msg.text || null,
        headers: {}, tags: msg.tags || [],
        status, idempotency_key: msg.idempotencyKey || null,
        reply_to: msg.replyTo || null,
        scheduled_at: scheduledAt || null,
        environment: msg.environment || "live",
        created_at: now, updated_at: now,
        retry_count: 0, max_retries: 3,
      }).execute();

      if (msg.attachmentIds && msg.attachmentIds.length > 0) {
        await db.updateTable("attachments").set({ email_message_id: emailId }).where("id", "in", msg.attachmentIds).execute();
      }
    }
    return { batchId, emailIds, count: messages.length };
  }

  async sendFromTemplate(organizationId: string, templateId: string, to: string, variables?: Record<string, string>, environment?: string): Promise<EmailResult> {
    const latestVersion = await db.selectFrom("template_versions").select(db.fn.max("version").as("max_version")).where("template_id", "=", templateId).executeTakeFirst();
    const template = await db.selectFrom("templates").innerJoin("template_versions", "template_versions.template_id", "templates.id").select(["templates.id", "templates.organization_id", "template_versions.subject", "template_versions.html_body", "template_versions.text_body"]).where("templates.id", "=", templateId).where("templates.organization_id", "=", organizationId).where("template_versions.is_published", "=", true).where("template_versions.version", "=", Number(latestVersion?.max_version || 0)).executeTakeFirst();
    if (!template) throw new NotFoundError("Template");
    const vars = variables || {};
    const domain = await db.selectFrom("domains").select("domain").where("organization_id", "=", organizationId).executeTakeFirst();
    const emailId = crypto.randomUUID();
    await db.insertInto("email_messages").values({
      id: emailId, organization_id: organizationId, batch_id: crypto.randomUUID(),
      template_id: templateId, domain_id: null,
      from_address: `noreply@${domain?.domain || "example.com"}`,
      to_address: to, recipient_type: "to",
      subject: renderTemplate(template.subject, vars),
      html_body: renderTemplate(template.html_body, vars),
      text_body: template.text_body ? renderTemplate(template.text_body, vars) : null,
      headers: {}, tags: [], status: "queued",
      idempotency_key: null, reply_to: null,
      environment: environment || "live",
      created_at: new Date(), updated_at: new Date(),
      retry_count: 0, max_retries: 3,
    }).execute();
    return { emailId, status: "queued" };
  }

  async list(organizationId: string, options: { page: number; perPage: number; status?: string; environment?: string; after?: string; limit?: number }): Promise<{ data: any[]; total: number; page: number; perPage: number; pages: number; nextCursor: string | undefined }> {
    const { page, perPage, status, environment, after, limit } = options;
    let query = db.selectFrom("email_messages").selectAll().where("organization_id", "=", organizationId).where("deleted_at", "is", null);
    if (status) query = query.where("status", "=", status);
    if (environment) query = query.where("environment", "=", environment);

    if (after) {
      const cursorLimit = limit || perPage;
      const cursorEmail = await db.selectFrom("email_messages").select("created_at").where("id", "=", after).executeTakeFirst();
      if (cursorEmail) {
        query = query.where("created_at", "<", cursorEmail.created_at);
      }
      const data = await query.orderBy("created_at", "desc").limit(cursorLimit).execute();
      const nextCursor = data.length === cursorLimit ? data[data.length - 1]?.id : undefined;
      return { data, total: 0, page, perPage: cursorLimit, pages: 0, nextCursor };
    }

    const [data, totalRow] = await Promise.all([
      query.orderBy("created_at", "desc").limit(perPage).offset((page - 1) * perPage).execute(),
      db.selectFrom("email_messages").select(sql<number>`count(*)::int`.as("count")).where("organization_id", "=", organizationId).where("deleted_at", "is", null).executeTakeFirstOrThrow(),
    ]);
    const total = Number(totalRow.count);
    return { data, total, page, perPage, pages: Math.ceil(total / perPage), nextCursor: undefined };
  }

  async get(organizationId: string, id: string): Promise<any> {
    const email = await db.selectFrom("email_messages").selectAll().where("id", "=", id).where("organization_id", "=", organizationId).executeTakeFirst();
    if (!email) throw new NotFoundError("Email");
    const deliveries = await db.selectFrom("deliveries").selectAll().where("email_message_id", "=", id).execute();
    return { ...email, deliveries };
  }

  async cancel(organizationId: string, id: string): Promise<void> {
    const email = await db.selectFrom("email_messages").select("status").where("id", "=", id).where("organization_id", "=", organizationId).executeTakeFirst();
    if (!email) throw new NotFoundError("Email");
    if (email.status !== "scheduled") throw new ValidationError("Only scheduled emails can be cancelled");
    await db.updateTable("email_messages").set({ status: "cancelled", updated_at: new Date() }).where("id", "=", id).execute();
  }
}
