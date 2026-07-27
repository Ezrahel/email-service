import { sql, type Kysely, type SqlBool } from "kysely";

export async function up(db: Kysely<unknown>): Promise<void> {
  await db.schema
    .createTable("event_logs")
    .addColumn("id", "uuid", (c) => c.primaryKey().defaultTo(sql`gen_random_uuid()`))
    .addColumn("event_type", "text", (c) => c.notNull())
    .addColumn("entity_type", "text", (c) => c.notNull())
    .addColumn("entity_id", "uuid")
    .addColumn("organization_id", "uuid", (c) => c.references("organizations.id").onDelete("cascade"))
    .addColumn("user_id", "uuid", (c) => c.references("users.id").onDelete("set null"))
    .addColumn("payload", "jsonb", (c) => c.notNull().defaultTo(sql`'{}'::jsonb`))
    .addColumn("metadata", "jsonb", (c) => c.notNull().defaultTo(sql`'{}'::jsonb`))
    .addColumn("created_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .execute();

  await db.schema
    .createIndex("idx_event_logs_event_type")
    .on("event_logs")
    .column("event_type")
    .execute();
  await db.schema
    .createIndex("idx_event_logs_entity")
    .on("event_logs")
    .columns(["entity_type", "entity_id"])
    .execute();
  await db.schema
    .createIndex("idx_event_logs_created_at")
    .on("event_logs")
    .column("created_at")
    .execute();

  await db.schema
    .createTable("audit_logs")
    .addColumn("id", "uuid", (c) => c.primaryKey().defaultTo(sql`gen_random_uuid()`))
    .addColumn("organization_id", "uuid", (c) => c.references("organizations.id").onDelete("cascade"))
    .addColumn("user_id", "uuid", (c) => c.references("users.id").onDelete("set null"))
    .addColumn("action", "text", (c) => c.notNull())
    .addColumn("resource_type", "text", (c) => c.notNull())
    .addColumn("resource_id", "text")
    .addColumn("old_values", "jsonb")
    .addColumn("new_values", "jsonb")
    .addColumn("ip_address", "text")
    .addColumn("user_agent", "text")
    .addColumn("created_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .execute();

  await db.schema
    .createIndex("idx_audit_logs_org_action")
    .on("audit_logs")
    .columns(["organization_id", "action"])
    .execute();
  await db.schema
    .createIndex("idx_audit_logs_resource")
    .on("audit_logs")
    .columns(["resource_type", "resource_id"])
    .execute();
  await db.schema
    .createIndex("idx_audit_logs_created_at")
    .on("audit_logs")
    .column("created_at")
    .execute();

  await db.schema
    .createTable("jobs")
    .addColumn("id", "uuid", (c) => c.primaryKey().defaultTo(sql`gen_random_uuid()`))
    .addColumn("job_type", "text", (c) => c.notNull())
    .addColumn("payload", "jsonb", (c) => c.notNull().defaultTo(sql`'{}'::jsonb`))
    .addColumn("status", "text", (c) => c.notNull().defaultTo("pending"))
    .addColumn("priority", "integer", (c) => c.notNull().defaultTo(0))
    .addColumn("scheduled_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .addColumn("started_at", "timestamptz")
    .addColumn("completed_at", "timestamptz")
    .addColumn("failed_at", "timestamptz")
    .addColumn("error_message", "text")
    .addColumn("retry_count", "integer", (c) => c.notNull().defaultTo(0))
    .addColumn("max_retries", "integer", (c) => c.notNull().defaultTo(3))
    .addColumn("next_retry_at", "timestamptz")
    .addColumn("locked_by", "text")
    .addColumn("locked_at", "timestamptz")
    .addColumn("created_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .addColumn("updated_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .execute();

  await db.schema
    .createIndex("idx_jobs_type_status")
    .on("jobs")
    .columns(["job_type", "status"])
    .execute();
  await db.schema
    .createIndex("idx_jobs_scheduled")
    .on("jobs")
    .column("scheduled_at")
    .where(sql<SqlBool>`scheduled_at IS NOT NULL AND status = 'pending'`)
    .execute();

  await db.schema
    .createTable("partition_management")
    .addColumn("id", "uuid", (c) => c.primaryKey().defaultTo(sql`gen_random_uuid()`))
    .addColumn("table_name", "text", (c) => c.notNull())
    .addColumn("partition_name", "text", (c) => c.notNull())
    .addColumn("partition_start", "timestamptz", (c) => c.notNull())
    .addColumn("partition_end", "timestamptz", (c) => c.notNull())
    .addColumn("row_count", "bigint")
    .addColumn("size_bytes", "bigint")
    .addColumn("is_attached", "boolean", (c) => c.notNull().defaultTo(true))
    .addColumn("created_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .addColumn("attached_at", "timestamptz")
    .addColumn("detached_at", "timestamptz")
    .execute();

  await db.schema
    .createIndex("idx_partition_management_table_name")
    .on("partition_management")
    .column("table_name")
    .execute();

  await db.schema
    .createTable("materialized_views")
    .addColumn("id", "uuid", (c) => c.primaryKey().defaultTo(sql`gen_random_uuid()`))
    .addColumn("view_name", "text", (c) => c.notNull())
    .addColumn("definition", "text", (c) => c.notNull())
    .addColumn("is_populated", "boolean", (c) => c.notNull().defaultTo(false))
    .addColumn("last_refreshed_at", "timestamptz")
    .addColumn("refresh_interval_seconds", "bigint")
    .addColumn("created_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .addColumn("updated_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .execute();

  await db.schema
    .createIndex("idx_materialized_views_view_name")
    .unique()
    .on("materialized_views")
    .column("view_name")
    .execute();

  await db.schema
    .createTable("retention_policies")
    .addColumn("id", "uuid", (c) => c.primaryKey().defaultTo(sql`gen_random_uuid()`))
    .addColumn("organization_id", "uuid", (c) => c.references("organizations.id").onDelete("cascade"))
    .addColumn("table_name", "text", (c) => c.notNull())
    .addColumn("retention_days", "integer", (c) => c.notNull().defaultTo(365))
    .addColumn("enabled", "boolean", (c) => c.notNull().defaultTo(true))
    .addColumn("created_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .addColumn("updated_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .execute();

  await db.schema
    .createIndex("idx_retention_policies_org_table")
    .unique()
    .on("retention_policies")
    .columns(["organization_id", "table_name"])
    .execute();
}

export async function down(db: Kysely<unknown>): Promise<void> {
  await db.schema.dropTable("retention_policies").ifExists().execute();
  await db.schema.dropTable("materialized_views").ifExists().execute();
  await db.schema.dropTable("partition_management").ifExists().execute();
  await db.schema.dropTable("jobs").ifExists().execute();
  await db.schema.dropTable("audit_logs").ifExists().execute();
  await db.schema.dropTable("event_logs").ifExists().execute();
}
