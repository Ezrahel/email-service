import { sql, type Kysely, type SqlBool } from "kysely";

export async function up(db: Kysely<unknown>): Promise<void> {
  await db.schema
    .createTable("email_messages")
    .addColumn("id", "uuid", (c) => c.primaryKey().defaultTo(sql`gen_random_uuid()`))
    .addColumn("organization_id", "uuid", (c) => c.notNull().references("organizations.id").onDelete("cascade"))
    .addColumn("batch_id", "uuid", (c) => c.notNull())
    .addColumn("template_id", "uuid", (c) => c.references("templates.id").onDelete("set null"))
    .addColumn("domain_id", "uuid", (c) => c.references("domains.id").onDelete("set null"))
    .addColumn("from_address", "text", (c) => c.notNull())
    .addColumn("to_address", "text", (c) => c.notNull())
    .addColumn("recipient_type", "text", (c) => c.notNull().defaultTo("to"))
    .addColumn("subject", "text", (c) => c.notNull())
    .addColumn("html_body", "text")
    .addColumn("text_body", "text")
    .addColumn("headers", "jsonb", (c) => c.notNull().defaultTo(sql`'{}'::jsonb`))
    .addColumn("tags", sql`text[]`, (c) => c.notNull().defaultTo(sql`'{}'::text[]`))
    .addColumn("status", "text", (c) => c.notNull().defaultTo("queued"))
    .addColumn("idempotency_key", "text")
    .addColumn("reply_to", "text")
    .addColumn("message_id", "text")
    .addColumn("retry_count", "integer", (c) => c.notNull().defaultTo(0))
    .addColumn("max_retries", "integer", (c) => c.notNull().defaultTo(3))
    .addColumn("scheduled_at", "timestamptz")
    .addColumn("sent_at", "timestamptz")
    .addColumn("delivered_at", "timestamptz")
    .addColumn("failed_at", "timestamptz")
    .addColumn("last_retry_at", "timestamptz")
    .addColumn("failure_reason", "text")
    .addColumn("failure_code", "text")
    .addColumn("created_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .addColumn("updated_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .addColumn("deleted_at", "timestamptz")
    .execute();

  await db.schema.createIndex("idx_email_messages_organization_id").on("email_messages").column("organization_id").execute();
  await db.schema.createIndex("idx_email_messages_batch_id").on("email_messages").column("batch_id").execute();
  await db.schema.createIndex("idx_email_messages_to_address").on("email_messages").column("to_address").execute();
  await db.schema.createIndex("idx_email_messages_status").on("email_messages").column("status").execute();
  await db.schema
    .createIndex("idx_email_messages_idempotency_key")
    .on("email_messages")
    .column("idempotency_key")
    .where("idempotency_key", "is not", null)
    .execute();
  await db.schema
    .createIndex("idx_email_messages_message_id")
    .on("email_messages")
    .column("message_id")
    .where("message_id", "is not", null)
    .execute();
  await db.schema
    .createIndex("idx_email_messages_org_status_created")
    .on("email_messages")
    .columns(["organization_id", "status", "created_at"])
    .execute();
  await db.schema
    .createIndex("idx_email_messages_org_created")
    .on("email_messages")
    .columns(["organization_id", "created_at"])
    .execute();
  await db.schema
    .createIndex("idx_email_messages_scheduled")
    .on("email_messages")
    .column("scheduled_at")
    .where(sql<SqlBool>`scheduled_at IS NOT NULL AND status = 'queued'`)
    .execute();
  await db.schema.createIndex("idx_email_messages_created_at").on("email_messages").column("created_at").execute();
  await db.schema.createIndex("idx_email_messages_tags").on("email_messages").column("tags").using("gin").execute();
  await db.schema.createIndex("idx_email_messages_deleted_at").on("email_messages").column("deleted_at").execute();

  await db.schema
    .createTable("attachments")
    .addColumn("id", "uuid", (c) => c.primaryKey().defaultTo(sql`gen_random_uuid()`))
    .addColumn("email_message_id", "uuid", (c) => c.notNull().references("email_messages.id").onDelete("cascade"))
    .addColumn("filename", "text", (c) => c.notNull())
    .addColumn("content_type", "text", (c) => c.notNull())
    .addColumn("size_bytes", "bigint", (c) => c.notNull())
    .addColumn("storage_path", "text", (c) => c.notNull())
    .addColumn("storage_provider", "text", (c) => c.notNull().defaultTo("s3"))
    .addColumn("checksum", "text", (c) => c.notNull())
    .addColumn("created_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .execute();

  await db.schema.createIndex("idx_attachments_email_message_id").on("attachments").column("email_message_id").execute();
}

export async function down(db: Kysely<unknown>): Promise<void> {
  await db.schema.dropTable("attachments").ifExists().execute();
  await db.schema.dropTable("email_messages").ifExists().execute();
}
