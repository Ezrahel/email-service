import { db } from "@resendbyte/database";
import { logger } from "@resendbyte/logger";

interface AuditEntry {
  organizationId?: string | null;
  userId?: string | null;
  action: string;
  resourceType: string;
  resourceId?: string | null;
  oldValues?: Record<string, unknown> | null;
  newValues?: Record<string, unknown> | null;
  ipAddress?: string | null;
  userAgent?: string | null;
}

export class AuditService {
  async log(entry: AuditEntry): Promise<void> {
    try {
      await db.insertInto("audit_logs").values({
        id: crypto.randomUUID(),
        organization_id: entry.organizationId ?? null,
        user_id: entry.userId ?? null,
        action: entry.action,
        resource_type: entry.resourceType,
        resource_id: entry.resourceId ?? null,
        old_values: entry.oldValues ? JSON.parse(JSON.stringify(entry.oldValues)) : null,
        new_values: entry.newValues ? JSON.parse(JSON.stringify(entry.newValues)) : null,
        ip_address: entry.ipAddress ?? null,
        user_agent: entry.userAgent ?? null,
        created_at: new Date(),
      }).execute();
    } catch (error) {
      logger.error({ error, entry }, "Failed to write audit log");
    }
  }

  async list(organizationId: string, page: number = 1, perPage: number = 50): Promise<{ data: any[]; meta: any }> {
    const offset = (page - 1) * perPage;
    const data = await db.selectFrom("audit_logs")
      .selectAll()
      .where("organization_id", "=", organizationId)
      .orderBy("created_at", "desc")
      .limit(perPage)
      .offset(offset)
      .execute();

    const countResult = await db.selectFrom("audit_logs")
      .select(db.fn.countAll<number>().as("count"))
      .where("organization_id", "=", organizationId)
      .execute();

    return {
      data,
      meta: { page, perPage, total: Number(countResult[0]?.count ?? 0) },
    };
  }
}
