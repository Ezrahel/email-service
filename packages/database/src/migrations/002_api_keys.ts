import { sql, type Kysely } from "kysely";

export async function up(db: Kysely<unknown>): Promise<void> {
  await db.schema
    .createTable("api_keys")
    .addColumn("id", "uuid", (c) => c.primaryKey().defaultTo(sql`gen_random_uuid()`))
    .addColumn("organization_id", "uuid", (c) => c.notNull().references("organizations.id").onDelete("cascade"))
    .addColumn("user_id", "uuid", (c) => c.references("users.id").onDelete("set null"))
    .addColumn("name", "text", (c) => c.notNull())
    .addColumn("key_prefix", "text", (c) => c.notNull())
    .addColumn("key_digest", "text", (c) => c.notNull())
    .addColumn("key_last_chars", "text", (c) => c.notNull())
    .addColumn("scopes", sql`text[]`, (c) => c.notNull().defaultTo(sql`'{}'::text[]`))
    .addColumn("allowed_ips", sql`text[]`, (c) => c.notNull().defaultTo(sql`'{}'::text[]`))
    .addColumn("status", "text", (c) => c.notNull().defaultTo("active"))
    .addColumn("expires_at", "timestamptz")
    .addColumn("last_used_at", "timestamptz")
    .addColumn("revoked_at", "timestamptz")
    .addColumn("created_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .addColumn("updated_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .addColumn("deleted_at", "timestamptz")
    .execute();

  await db.schema.createIndex("idx_api_keys_organization_id").on("api_keys").column("organization_id").execute();
  await db.schema.createIndex("idx_api_keys_key_digest").unique().on("api_keys").column("key_digest").execute();
  await db.schema.createIndex("idx_api_keys_key_prefix").on("api_keys").column("key_prefix").execute();
  await db.schema.createIndex("idx_api_keys_status").on("api_keys").column("status").execute();
  await db.schema.createIndex("idx_api_keys_deleted_at").on("api_keys").column("deleted_at").execute();
}

export async function down(db: Kysely<unknown>): Promise<void> {
  await db.schema.dropTable("api_keys").ifExists().execute();
}
