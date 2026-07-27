import crypto from "node:crypto";
import { createWorker, QUEUE_NAMES, type MaintenanceJob, type DomainVerificationJob } from "@email-service/queue";
import { db } from "@email-service/database";
import { logger } from "@email-service/logger";
import { sql } from "kysely";

async function handleMaintenance(job: { task: string }): Promise<void> {
  switch (job.task) {
    case "cleanup": {
      const cutoff = new Date(Date.now() - 90 * 86400000);
      const deleted = await db.deleteFrom("event_logs").where("created_at", "<", cutoff).execute();
      logger.info({ deletedCount: deleted.length || 0, task: "cleanup" }, "Cleanup completed");
      break;
    }
    case "retention": {
      const policies = await db.selectFrom("retention_policies").selectAll().where("enabled", "=", true).execute();
      for (const policy of policies) {
        const retentionCutoff = new Date(Date.now() - policy.retention_days * 86400000);
        await sql`DELETE FROM ${sql.table(policy.table_name)} WHERE created_at < ${sql.val(retentionCutoff)}`.execute(db);
        logger.debug({ table: policy.table_name, days: policy.retention_days }, "Retention policy applied");
      }
      break;
    }
    default:
      logger.debug({ task: job.task }, "Unknown maintenance task");
  }
}

async function verifyDomain(job: { domainId: string; organizationId: string }): Promise<void> {
  const domain = await db.selectFrom("domains").selectAll().where("id", "=", job.domainId).where("deleted_at", "is", null).executeTakeFirst();
  if (!domain) return;

  try {
    const dns = await fetch(`https://dns.google/resolve?name=${domain.domain}&type=TXT`);
    const data = await dns.json() as { Answer?: Array<{ data: string }> };
    const records = data.Answer?.map((a: { data: string }) => a.data) || [];

    const dkimFound = records.some((r: string) => r.includes(`v=DKIM1;`));
    const spfFound = records.some((r: string) => r.startsWith("v=spf1"));

    await db.updateTable("domains").set({
      dkim_verified: dkimFound,
      spf_verified: spfFound,
      dkim_verified_at: dkimFound ? new Date() : null,
      spf_verified_at: spfFound ? new Date() : null,
      status: dkimFound && spfFound ? "verified" : "pending",
      updated_at: new Date(),
    }).where("id", "=", domain.id).execute();
  } catch (error) {
    logger.error({ error: String(error), domainId: job.domainId }, "Domain verification failed");
  }
}

createWorker<MaintenanceJob>(QUEUE_NAMES.MAINTENANCE, (job) => handleMaintenance(job.data), { concurrency: 1, lockDuration: 300000 });
createWorker<DomainVerificationJob>(QUEUE_NAMES.EMAIL_DEFAULT, (job) => verifyDomain(job.data), { concurrency: 5 });

logger.info("Scheduled workers started");
