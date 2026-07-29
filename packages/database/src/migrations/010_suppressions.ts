import { sql, type Kysely } from "kysely";

export async function up(db: Kysely<unknown>): Promise<void> {
  await db.schema
    .createTable("suppressions")
    .addColumn("id", "uuid", (c) => c.primaryKey().defaultTo(sql`gen_random_uuid()`))
    .addColumn("organization_id", "uuid", (c) => c.notNull().references("organizations.id").onDelete("cascade"))
    .addColumn("email", "text", (c) => c.notNull())
    .addColumn("reason", "text", (c) => c.notNull())
    .addColumn("source", "text", (c) => c.notNull().defaultTo("manual"))
    .addColumn("created_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .execute();

  await db.schema
    .createIndex("idx_suppressions_org_email")
    .unique()
    .on("suppressions")
    .columns(["organization_id", "email"])
    .execute();

  await db.schema
    .createIndex("idx_suppressions_org_reason")
    .on("suppressions")
    .columns(["organization_id", "reason"])
    .execute();
}

export async function down(db: Kysely<unknown>): Promise<void> {
  await db.schema.dropTable("suppressions").ifExists().execute();
}
