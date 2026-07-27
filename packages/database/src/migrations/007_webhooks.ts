import { sql, type Kysely, type SqlBool } from "kysely";

export async function up(db: Kysely<unknown>): Promise<void> {
  await db.schema
    .createTable("webhooks")
    .addColumn("id", "uuid", (c) => c.primaryKey().defaultTo(sql`gen_random_uuid()`))
    .addColumn("organization_id", "uuid", (c) => c.notNull().references("organizations.id").onDelete("cascade"))
    .addColumn("url", "text", (c) => c.notNull())
    .addColumn("secret_ciphertext", "text", (c) => c.notNull())
    .addColumn("events", sql`text[]`, (c) => c.notNull().defaultTo(sql`'{}'::text[]`))
    .addColumn("status", "text", (c) => c.notNull().defaultTo("active"))
    .addColumn("failure_count", "integer", (c) => c.notNull().defaultTo(0))
    .addColumn("last_success_at", "timestamptz")
    .addColumn("last_failure_at", "timestamptz")
    .addColumn("last_failure_reason", "text")
    .addColumn("created_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .addColumn("updated_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .addColumn("deleted_at", "timestamptz")
    .execute();

  await db.schema.createIndex("idx_webhooks_organization_id").on("webhooks").column("organization_id").execute();
  await db.schema.createIndex("idx_webhooks_status").on("webhooks").column("status").execute();
  await db.schema.createIndex("idx_webhooks_deleted_at").on("webhooks").column("deleted_at").execute();

  await db.schema
    .createTable("webhook_deliveries")
    .addColumn("id", "uuid", (c) => c.primaryKey().defaultTo(sql`gen_random_uuid()`))
    .addColumn("webhook_id", "uuid", (c) => c.notNull().references("webhooks.id").onDelete("cascade"))
    .addColumn("event_type", "text", (c) => c.notNull())
    .addColumn("payload", "jsonb", (c) => c.notNull())
    .addColumn("response_status", "integer")
    .addColumn("response_body", "text")
    .addColumn("error_message", "text")
    .addColumn("attempt", "integer", (c) => c.notNull().defaultTo(1))
    .addColumn("next_retry_at", "timestamptz")
    .addColumn("delivered_at", "timestamptz")
    .addColumn("failed_at", "timestamptz")
    .addColumn("created_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .execute();

  await db.schema.createIndex("idx_webhook_deliveries_webhook_id").on("webhook_deliveries").column("webhook_id").execute();
  await db.schema
    .createIndex("idx_webhook_deliveries_retry")
    .on("webhook_deliveries")
    .column("next_retry_at")
    .where(sql<SqlBool>`next_retry_at IS NOT NULL AND delivered_at IS NULL AND failed_at IS NULL`)
    .execute();
}

export async function down(db: Kysely<unknown>): Promise<void> {
  await db.schema.dropTable("webhook_deliveries").ifExists().execute();
  await db.schema.dropTable("webhooks").ifExists().execute();
}
