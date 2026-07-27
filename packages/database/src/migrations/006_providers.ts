import { sql, type Kysely, type SqlBool } from "kysely";

export async function up(db: Kysely<unknown>): Promise<void> {
  await db.schema
    .createTable("provider_configs")
    .addColumn("id", "uuid", (c) => c.primaryKey().defaultTo(sql`gen_random_uuid()`))
    .addColumn("organization_id", "uuid", (c) => c.notNull().references("organizations.id").onDelete("cascade"))
    .addColumn("provider_type", "text", (c) => c.notNull())
    .addColumn("name", "text", (c) => c.notNull())
    .addColumn("credentials_ciphertext", "text", (c) => c.notNull())
    .addColumn("settings", "jsonb", (c) => c.notNull().defaultTo(sql`'{}'::jsonb`))
    .addColumn("weight", "integer", (c) => c.notNull().defaultTo(1))
    .addColumn("is_active", "boolean", (c) => c.notNull().defaultTo(true))
    .addColumn("daily_limit", "integer")
    .addColumn("monthly_limit", "integer")
    .addColumn("created_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .addColumn("updated_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .addColumn("deleted_at", "timestamptz")
    .execute();

  await db.schema.createIndex("idx_provider_configs_organization_id").on("provider_configs").column("organization_id").execute();
  await db.schema
    .createIndex("idx_provider_configs_org_active")
    .on("provider_configs")
    .columns(["organization_id", "is_active"])
    .execute();
  await db.schema.createIndex("idx_provider_configs_deleted_at").on("provider_configs").column("deleted_at").execute();

  await db.schema
    .createTable("deliveries")
    .addColumn("id", "uuid", (c) => c.primaryKey().defaultTo(sql`gen_random_uuid()`))
    .addColumn("email_message_id", "uuid", (c) => c.notNull().references("email_messages.id").onDelete("cascade"))
    .addColumn("provider_config_id", "uuid", (c) => c.notNull().references("provider_configs.id").onDelete("restrict"))
    .addColumn("provider_type", "text", (c) => c.notNull())
    .addColumn("provider_message_id", "text")
    .addColumn("status", "text", (c) => c.notNull().defaultTo("pending"))
    .addColumn("scheduled_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .addColumn("sent_at", "timestamptz")
    .addColumn("delivered_at", "timestamptz")
    .addColumn("failed_at", "timestamptz")
    .addColumn("failure_reason", "text")
    .addColumn("failure_code", "text")
    .addColumn("retry_count", "integer", (c) => c.notNull().defaultTo(0))
    .addColumn("next_retry_at", "timestamptz")
    .addColumn("created_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .addColumn("updated_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .execute();

  await db.schema.createIndex("idx_deliveries_email_message_id").on("deliveries").column("email_message_id").execute();
  await db.schema.createIndex("idx_deliveries_provider_config_id").on("deliveries").column("provider_config_id").execute();
  await db.schema.createIndex("idx_deliveries_status").on("deliveries").column("status").execute();
  await db.schema
    .createIndex("idx_deliveries_provider_message_id")
    .on("deliveries")
    .column("provider_message_id")
    .where("provider_message_id", "is not", null)
    .execute();
  await db.schema
    .createIndex("idx_deliveries_retry")
    .on("deliveries")
    .column("next_retry_at")
    .where(sql<SqlBool>`next_retry_at IS NOT NULL AND status = 'retrying'`)
    .execute();

  await db.schema
    .createTable("provider_attempts")
    .addColumn("id", "uuid", (c) => c.primaryKey().defaultTo(sql`gen_random_uuid()`))
    .addColumn("delivery_id", "uuid", (c) => c.notNull().references("deliveries.id").onDelete("cascade"))
    .addColumn("provider_type", "text", (c) => c.notNull())
    .addColumn("provider_message_id", "text")
    .addColumn("request_payload", "jsonb")
    .addColumn("response_payload", "jsonb")
    .addColumn("status_code", "integer")
    .addColumn("error_message", "text")
    .addColumn("error_code", "text")
    .addColumn("duration_ms", "integer", (c) => c.notNull().defaultTo(0))
    .addColumn("attempted_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .execute();

  await db.schema.createIndex("idx_provider_attempts_delivery_id").on("provider_attempts").column("delivery_id").execute();

  await db.schema
    .createTable("delivery_events")
    .addColumn("id", "uuid", (c) => c.primaryKey().defaultTo(sql`gen_random_uuid()`))
    .addColumn("delivery_id", "uuid", (c) => c.notNull().references("deliveries.id").onDelete("cascade"))
    .addColumn("event_type", "text", (c) => c.notNull())
    .addColumn("event_data", "jsonb", (c) => c.notNull().defaultTo(sql`'{}'::jsonb`))
    .addColumn("received_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .addColumn("processed_at", "timestamptz")
    .addColumn("processing_error", "text")
    .execute();

  await db.schema.createIndex("idx_delivery_events_delivery_id").on("delivery_events").column("delivery_id").execute();
  await db.schema
    .createIndex("idx_delivery_events_unprocessed")
    .on("delivery_events")
    .column("received_at")
    .where(sql<SqlBool>`processed_at IS NULL`)
    .execute();
}

export async function down(db: Kysely<unknown>): Promise<void> {
  await db.schema.dropTable("delivery_events").ifExists().execute();
  await db.schema.dropTable("provider_attempts").ifExists().execute();
  await db.schema.dropTable("deliveries").ifExists().execute();
  await db.schema.dropTable("provider_configs").ifExists().execute();
}
