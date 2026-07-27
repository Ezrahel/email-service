import { db } from "@email-service/database";
import { sql } from "kysely";

export class OrganizationService {
  async getUsage(organizationId: string): Promise<{ sentThisMonth: number; limit: number; monthStart: Date }> {
    const org = await db.selectFrom("organizations").select(["emails_sent_this_month", "monthly_email_limit", "month_start_date"]).where("id", "=", organizationId).executeTakeFirst();
    if (!org) return { sentThisMonth: 0, limit: 100000, monthStart: new Date() };
    return { sentThisMonth: org.emails_sent_this_month, limit: org.monthly_email_limit, monthStart: org.month_start_date };
  }

  async incrementUsage(organizationId: string): Promise<void> {
    await sql`UPDATE organizations SET emails_sent_this_month = emails_sent_this_month + 1 WHERE id = ${organizationId}`.execute(db);
  }
}
