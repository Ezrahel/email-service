import { sql, type Kysely } from "kysely";

export async function up(db: Kysely<unknown>): Promise<void> {
  await db.schema
    .createTable("domains")
    .addColumn("id", "uuid", (c) => c.primaryKey().defaultTo(sql`gen_random_uuid()`))
    .addColumn("organization_id", "uuid", (c) => c.notNull().references("organizations.id").onDelete("cascade"))
    .addColumn("domain", "text", (c) => c.notNull())
    .addColumn("dkim_selector", "text", (c) => c.notNull().defaultTo("em"))
    .addColumn("dkim_private_key_ciphertext", "text")
    .addColumn("dkim_public_key", "text")
    .addColumn("dkim_verified", "boolean", (c) => c.notNull().defaultTo(false))
    .addColumn("dkim_verified_at", "timestamptz")
    .addColumn("spf_verified", "boolean", (c) => c.notNull().defaultTo(false))
    .addColumn("spf_verified_at", "timestamptz")
    .addColumn("dmarc_verified", "boolean", (c) => c.notNull().defaultTo(false))
    .addColumn("dmarc_verified_at", "timestamptz")
    .addColumn("tracking_enabled", "boolean", (c) => c.notNull().defaultTo(true))
    .addColumn("tracking_domain", "text")
    .addColumn("status", "text", (c) => c.notNull().defaultTo("pending"))
    .addColumn("created_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .addColumn("updated_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .addColumn("deleted_at", "timestamptz")
    .execute();

  await db.schema
    .createIndex("idx_domains_org_domain")
    .unique()
    .on("domains")
    .columns(["organization_id", "domain"])
    .execute();
  await db.schema.createIndex("idx_domains_status").on("domains").column("status").execute();
  await db.schema.createIndex("idx_domains_deleted_at").on("domains").column("deleted_at").execute();

  await db.schema
    .createTable("dns_records")
    .addColumn("id", "uuid", (c) => c.primaryKey().defaultTo(sql`gen_random_uuid()`))
    .addColumn("domain_id", "uuid", (c) => c.notNull().references("domains.id").onDelete("cascade"))
    .addColumn("type", "text", (c) => c.notNull())
    .addColumn("name", "text", (c) => c.notNull())
    .addColumn("value", "text", (c) => c.notNull())
    .addColumn("priority", "integer")
    .addColumn("ttl", "integer", (c) => c.notNull().defaultTo(3600))
    .addColumn("verified", "boolean", (c) => c.notNull().defaultTo(false))
    .addColumn("verified_at", "timestamptz")
    .addColumn("created_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .addColumn("updated_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .execute();

  await db.schema.createIndex("idx_dns_records_domain_id").on("dns_records").column("domain_id").execute();
  await db.schema.createIndex("idx_dns_records_type").on("dns_records").column("type").execute();
}

export async function down(db: Kysely<unknown>): Promise<void> {
  await db.schema.dropTable("dns_records").ifExists().execute();
  await db.schema.dropTable("domains").ifExists().execute();
}
