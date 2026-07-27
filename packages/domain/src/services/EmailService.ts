import { db } from "@email-service/database";
import { sql } from "kysely";
import { ValidationError, NotFoundError } from "@email-service/errors";
import crypto from "node:crypto";

export interface SendEmailInput {
  from: string; to: string | string[]; subject: string;
  html?: string; text?: string; replyTo?: string;
  tags?: string[]; idempotencyKey?: string;
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
  async send(organizationId: string, from: string, to: string, subject: string, html?: string, text?: string, replyTo?: string, tags?: string[], idempotencyKey?: string): Promise<EmailResult> {
    const emailId = crypto.randomUUID();
    await db.insertInto("email_messages").values({
      id: emailId, organization_id: organizationId, batch_id: crypto.randomUUID(),
      from_address: from, to_address: to, recipient_type: "to",
      subject, html_body: html || null, text_body: text || null,
      headers: {}, tags: tags || [],
      status: "queued", idempotency_key: idempotencyKey || null,
      reply_to: replyTo || null,
      created_at: new Date(), updated_at: new Date(),
      retry_count: 0, max_retries: 3,
    }).execute();
    return { emailId, status: "queued" };
  }

  async sendBatch(organizationId: string, messages: SendEmailInput[]): Promise<{ batchId: string; emailIds: string[]; count: number }> {
    if (messages.length > 1000) throw new ValidationError("Batch limit is 1000 messages");
    const batchId = crypto.randomUUID();
    const emailIds: string[] = [];
    for (const msg of messages) {
      const emailId = crypto.randomUUID();
      emailIds.push(emailId);
      const toAddress = Array.isArray(msg.to) ? msg.to.join(", ") : msg.to;
      await db.insertInto("email_messages").values({
        id: crypto.randomUUID(), organization_id: organizationId, batch_id: batchId,
        from_address: msg.from, to_address: toAddress, recipient_type: "to",
        subject: msg.subject, html_body: msg.html || null, text_body: msg.text || null,
        headers: {}, tags: msg.tags || [],
        status: "queued", idempotency_key: msg.idempotencyKey || null,
        reply_to: msg.replyTo || null,
        created_at: new Date(), updated_at: new Date(),
        retry_count: 0, max_retries: 3,
      }).execute();
    }
    return { batchId, emailIds, count: messages.length };
  }

  async sendFromTemplate(organizationId: string, templateId: string, to: string, variables?: Record<string, string>): Promise<EmailResult> {
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
      created_at: new Date(), updated_at: new Date(),
      retry_count: 0, max_retries: 3,
    }).execute();
    return { emailId, status: "queued" };
  }

  async list(organizationId: string, options: { page: number; perPage: number; status?: string }): Promise<{ data: any[]; total: number; page: number; perPage: number; pages: number }> {
    const { page, perPage, status } = options;
    let query = db.selectFrom("email_messages").selectAll().where("organization_id", "=", organizationId).where("deleted_at", "is", null);
    if (status) query = query.where("status", "=", status);
    const [data, totalRow] = await Promise.all([
      query.orderBy("created_at", "desc").limit(perPage).offset((page - 1) * perPage).execute(),
      db.selectFrom("email_messages").select(sql<number>`count(*)::int`.as("count")).where("organization_id", "=", organizationId).where("deleted_at", "is", null).executeTakeFirstOrThrow(),
    ]);
    const total = Number(totalRow.count);
    return { data, total, page, perPage, pages: Math.ceil(total / perPage) };
  }

  async get(organizationId: string, id: string): Promise<any> {
    const email = await db.selectFrom("email_messages").selectAll().where("id", "=", id).where("organization_id", "=", organizationId).executeTakeFirst();
    if (!email) throw new NotFoundError("Email");
    const deliveries = await db.selectFrom("deliveries").selectAll().where("email_message_id", "=", id).execute();
    return { ...email, deliveries };
  }
}
