import { db, sql } from "@resendbyte/database";
import { NotFoundError } from "@resendbyte/errors";
import crypto from "node:crypto";

export type SuppressionReason = "hard_bounce" | "complaint" | "manual" | "unsubscribed";
export type SuppressionSource = "manual" | "automatic";

export class SuppressionService {
  async list(
    organizationId: string,
    options: { page: number; perPage: number; reason?: string }
  ): Promise<{ data: any[]; total: number; page: number; perPage: number; pages: number }> {
    const { page, perPage, reason } = options;
    let query = db.selectFrom("suppressions").selectAll().where("organization_id", "=", organizationId);
    if (reason) query = query.where("reason", "=", reason);

    let countQuery = db.selectFrom("suppressions").select(sql<number>`count(*)::int`.as("count")).where("organization_id", "=", organizationId);
    if (reason) countQuery = countQuery.where("reason", "=", reason);

    const [data, totalRow] = await Promise.all([
      query.orderBy("created_at", "desc").limit(perPage).offset((page - 1) * perPage).execute(),
      countQuery.executeTakeFirstOrThrow(),
    ]);
    const total = Number(totalRow.count);
    return { data, total, page, perPage, pages: Math.ceil(total / perPage) };
  }

  async add(
    organizationId: string,
    email: string,
    reason: SuppressionReason,
    source: SuppressionSource = "manual"
  ): Promise<{ id: string }> {
    const normalized = email.toLowerCase().trim();
    const existing = await db.selectFrom("suppressions").select("id").where("organization_id", "=", organizationId).where("email", "=", normalized).executeTakeFirst();
    if (existing) return { id: existing.id };

    const { id } = await db.insertInto("suppressions").values({
      id: crypto.randomUUID(),
      organization_id: organizationId,
      email: normalized,
      reason,
      source,
      created_at: new Date(),
    }).returning("id").executeTakeFirstOrThrow();

    return { id };
  }

  async remove(organizationId: string, email: string): Promise<void> {
    const normalized = email.toLowerCase().trim();
    const result = await db.deleteFrom("suppressions").where("organization_id", "=", organizationId).where("email", "=", normalized).executeTakeFirst();
    if (result.numDeletedRows === 0n) throw new NotFoundError("Suppression");
  }

  async removeById(organizationId: string, id: string): Promise<void> {
    const result = await db.deleteFrom("suppressions").where("id", "=", id).where("organization_id", "=", organizationId).executeTakeFirst();
    if (result.numDeletedRows === 0n) throw new NotFoundError("Suppression");
  }

  async isSuppressed(organizationId: string, email: string): Promise<boolean> {
    const normalized = email.toLowerCase().trim();
    const row = await db.selectFrom("suppressions").select("id").where("organization_id", "=", organizationId).where("email", "=", normalized).executeTakeFirst();
    return !!row;
  }
}
