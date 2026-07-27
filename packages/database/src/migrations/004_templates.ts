import { sql, type Kysely } from "kysely";

export async function up(db: Kysely<unknown>): Promise<void> {
  await db.schema
    .createTable("templates")
    .addColumn("id", "uuid", (c) => c.primaryKey().defaultTo(sql`gen_random_uuid()`))
    .addColumn("organization_id", "uuid", (c) => c.notNull().references("organizations.id").onDelete("cascade"))
    .addColumn("name", "text", (c) => c.notNull())
    .addColumn("slug", "text", (c) => c.notNull())
    .addColumn("description", "text")
    .addColumn("current_version_id", "uuid")
    .addColumn("created_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .addColumn("updated_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .addColumn("deleted_at", "timestamptz")
    .execute();

  await db.schema
    .createIndex("idx_templates_org_slug")
    .unique()
    .on("templates")
    .columns(["organization_id", "slug"])
    .execute();
  await db.schema.createIndex("idx_templates_deleted_at").on("templates").column("deleted_at").execute();

  await db.schema
    .createTable("template_versions")
    .addColumn("id", "uuid", (c) => c.primaryKey().defaultTo(sql`gen_random_uuid()`))
    .addColumn("template_id", "uuid", (c) => c.notNull().references("templates.id").onDelete("cascade"))
    .addColumn("version", "integer", (c) => c.notNull())
    .addColumn("subject", "text", (c) => c.notNull())
    .addColumn("html_body", "text", (c) => c.notNull())
    .addColumn("text_body", "text")
    .addColumn("variables", "jsonb", (c) => c.notNull().defaultTo(sql`'{}'::jsonb`))
    .addColumn("layout", "text")
    .addColumn("is_published", "boolean", (c) => c.notNull().defaultTo(false))
    .addColumn("published_at", "timestamptz")
    .addColumn("created_by", "uuid", (c) => c.references("users.id").onDelete("set null"))
    .addColumn("created_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .execute();

  await db.schema
    .createIndex("idx_template_versions_template_version")
    .unique()
    .on("template_versions")
    .columns(["template_id", "version"])
    .execute();

  await db.schema
    .alterTable("templates")
    .addForeignKeyConstraint(
      "fk_templates_current_version",
      ["current_version_id"],
      "template_versions",
      ["id"]
    )
    .onDelete("set null")
    .execute();
}

export async function down(db: Kysely<unknown>): Promise<void> {
  await db.schema
    .alterTable("templates")
    .dropConstraint("fk_templates_current_version")
    .ifExists()
    .execute();
  await db.schema.dropTable("template_versions").ifExists().execute();
  await db.schema.dropTable("templates").ifExists().execute();
}
