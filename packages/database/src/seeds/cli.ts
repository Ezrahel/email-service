import crypto from "node:crypto";
import { db, closeDatabase } from "../index.js";
import { logger } from "@resendbyte/logger";
import { hashPassword, generateAPIKey } from "@resendbyte/crypto";

async function seed() {
  logger.info("Seeding database...");

  const existing = await db.selectFrom("roles").select("id").where("name", "=", "admin").executeTakeFirst();
  if (existing) {
    logger.info("Database already seeded, skipping");
    await closeDatabase();
    return;
  }

  const now = new Date();

  await db.insertInto("roles").values({ id: crypto.randomUUID(), name: "admin", description: "Full access", permissions: ["*"], created_at: now, updated_at: now }).execute();

  await db.insertInto("roles").values({ id: crypto.randomUUID(), name: "member", description: "Limited access", permissions: ["email:send", "email:read", "template:manage"], created_at: now, updated_at: now }).execute();

  const roles = await db.selectFrom("roles").selectAll().execute();
  const adminRole = roles.find((r) => r.name === "admin")!;
  const orgId = crypto.randomUUID();
  const userId = crypto.randomUUID();

  await db.insertInto("organizations").values({
    id: orgId, name: "Demo Organization", slug: "demo", settings: {},
    ip_allowlist_enabled: false, ip_allowlist: [],
    monthly_email_limit: 100000, emails_sent_this_month: 0,
    month_start_date: new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), 1)),
    overage_enabled: false,
    status: "active", created_at: now, updated_at: now,
  }).execute();

  const passwordHash = await hashPassword("password123");
  await db.insertInto("users").values({
    id: userId, email: "admin@example.com", password_hash: passwordHash,
    first_name: "Admin", last_name: "User",
    timezone: "UTC", locale: "en", status: "active",
    failed_login_attempts: 0, email_verified_at: now,
    created_at: now, updated_at: now,
  }).execute();

  await db.insertInto("memberships").values({
    id: crypto.randomUUID(), user_id: userId, organization_id: orgId,
    role_id: adminRole.id, status: "active",
    joined_at: now, created_at: now, updated_at: now,
  }).execute();

  const { prefix, fullKey, digest, lastChars } = await generateAPIKey();
  await db.insertInto("api_keys").values({
    id: crypto.randomUUID(), organization_id: orgId, user_id: userId,
    name: "Demo API Key",
    key_prefix: prefix!, key_digest: digest!, key_last_chars: lastChars!,
    scopes: ["email:send", "email:read", "template:manage", "webhook:manage", "api_key:manage"],
    allowed_ips: [], status: "active",
    created_at: now, updated_at: now,
  }).execute();

  logger.info({ orgId, userId, apiKey: fullKey }, "Seed complete");
  await closeDatabase();
}

seed().catch((err) => {
  logger.error({ error: String(err) }, "Seed failed");
  process.exit(1);
});
