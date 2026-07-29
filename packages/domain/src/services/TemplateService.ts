import { db } from "@resendbyte/database";
import { sql } from "kysely";
import { NotFoundError } from "@resendbyte/errors";
import crypto from "node:crypto";

export interface CreateTemplateInput {
  name: string; subject: string; htmlBody: string; textBody?: string;
}

export interface TemplateResult {
  id: string; name: string; slug: string; created_at: Date;
}

export class TemplateService {
  async list(organizationId: string, page: number, perPage: number): Promise<{ data: TemplateResult[]; total: number; page: number; perPage: number; pages: number }> {
    const [data, totalRow] = await Promise.all([
      db.selectFrom("templates").selectAll().where("organization_id", "=", organizationId).where("deleted_at", "is", null).orderBy("created_at", "desc").limit(perPage).offset((page - 1) * perPage).execute(),
      db.selectFrom("templates").select(sql<number>`count(*)::int`.as("count")).where("organization_id", "=", organizationId).where("deleted_at", "is", null).executeTakeFirstOrThrow(),
    ]);
    const total = Number(totalRow.count);
    return { data, total, page, perPage, pages: Math.ceil(total / perPage) };
  }

  async create(organizationId: string, input: CreateTemplateInput): Promise<TemplateResult> {
    const template = await db.insertInto("templates").values({
      id: crypto.randomUUID(), organization_id: organizationId,
      name: input.name, slug: input.name.toLowerCase().replace(/\s+/g, "-"),
      current_version_id: null, created_at: new Date(), updated_at: new Date(),
    }).returningAll().executeTakeFirstOrThrow();
    await db.insertInto("template_versions").values({
      id: crypto.randomUUID(), template_id: template.id, version: 1,
      subject: input.subject, html_body: input.htmlBody,
      text_body: input.textBody || null, variables: {},
      is_published: false, created_at: new Date(),
    }).execute();
    return template;
  }

  async get(organizationId: string, id: string): Promise<any> {
    const template = await db.selectFrom("templates").selectAll().where("id", "=", id).where("organization_id", "=", organizationId).where("deleted_at", "is", null).executeTakeFirst();
    if (!template) throw new NotFoundError("Template");
    const versions = await db.selectFrom("template_versions").selectAll().where("template_id", "=", id).orderBy("version", "desc").execute();
    return { ...template, versions };
  }
}
