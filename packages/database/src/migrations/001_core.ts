import { sql, type Kysely } from "kysely";

export async function up(db: Kysely<unknown>): Promise<void> {
  await sql`CREATE EXTENSION IF NOT EXISTS pgcrypto`.execute(db);

  await db.schema
    .createTable("organizations")
    .addColumn("id", "uuid", (c) => c.primaryKey().defaultTo(sql`gen_random_uuid()`))
    .addColumn("name", "text", (c) => c.notNull())
    .addColumn("slug", "text", (c) => c.notNull())
    .addColumn("settings", "jsonb", (c) => c.notNull().defaultTo(sql`'{}'::jsonb`))
    .addColumn("ip_allowlist_enabled", "boolean", (c) => c.notNull().defaultTo(false))
    .addColumn("ip_allowlist", sql`text[]`, (c) => c.notNull().defaultTo(sql`'{}'::text[]`))
    .addColumn("monthly_email_limit", "integer", (c) => c.notNull().defaultTo(100000))
    .addColumn("emails_sent_this_month", "integer", (c) => c.notNull().defaultTo(0))
    .addColumn("month_start_date", "timestamptz", (c) => c.notNull().defaultTo(sql`date_trunc('month', now())`))
    .addColumn("status", "text", (c) => c.notNull().defaultTo("active"))
    .addColumn("created_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .addColumn("updated_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .addColumn("deleted_at", "timestamptz")
    .execute();

  await db.schema.createIndex("idx_organizations_slug").unique().on("organizations").column("slug").execute();
  await db.schema.createIndex("idx_organizations_status").on("organizations").column("status").execute();
  await db.schema.createIndex("idx_organizations_deleted_at").on("organizations").column("deleted_at").execute();

  await db.schema
    .createTable("roles")
    .addColumn("id", "uuid", (c) => c.primaryKey().defaultTo(sql`gen_random_uuid()`))
    .addColumn("name", "text", (c) => c.notNull())
    .addColumn("description", "text")
    .addColumn("permissions", sql`text[]`, (c) => c.notNull().defaultTo(sql`'{}'::text[]`))
    .addColumn("created_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .addColumn("updated_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .execute();

  await db.schema.createIndex("idx_roles_name").unique().on("roles").column("name").execute();

  await db.schema
    .createTable("users")
    .addColumn("id", "uuid", (c) => c.primaryKey().defaultTo(sql`gen_random_uuid()`))
    .addColumn("email", "text", (c) => c.notNull())
    .addColumn("password_hash", "text", (c) => c.notNull())
    .addColumn("first_name", "text", (c) => c.notNull().defaultTo(""))
    .addColumn("last_name", "text", (c) => c.notNull().defaultTo(""))
    .addColumn("timezone", "text", (c) => c.notNull().defaultTo("UTC"))
    .addColumn("locale", "text", (c) => c.notNull().defaultTo("en"))
    .addColumn("status", "text", (c) => c.notNull().defaultTo("active"))
    .addColumn("failed_login_attempts", "integer", (c) => c.notNull().defaultTo(0))
    .addColumn("locked_until", "timestamptz")
    .addColumn("last_login_at", "timestamptz")
    .addColumn("email_verified_at", "timestamptz")
    .addColumn("created_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .addColumn("updated_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .addColumn("deleted_at", "timestamptz")
    .execute();

  await db.schema.createIndex("idx_users_email").unique().on("users").column("email").execute();
  await db.schema.createIndex("idx_users_status").on("users").column("status").execute();
  await db.schema.createIndex("idx_users_deleted_at").on("users").column("deleted_at").execute();

  await db.schema
    .createTable("memberships")
    .addColumn("id", "uuid", (c) => c.primaryKey().defaultTo(sql`gen_random_uuid()`))
    .addColumn("user_id", "uuid", (c) => c.notNull().references("users.id").onDelete("cascade"))
    .addColumn("organization_id", "uuid", (c) => c.notNull().references("organizations.id").onDelete("cascade"))
    .addColumn("role_id", "uuid", (c) => c.notNull().references("roles.id").onDelete("restrict"))
    .addColumn("status", "text", (c) => c.notNull().defaultTo("active"))
    .addColumn("joined_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .addColumn("created_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .addColumn("updated_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .execute();

  await db.schema
    .createIndex("idx_memberships_user_org")
    .unique()
    .on("memberships")
    .columns(["user_id", "organization_id"])
    .execute();
  await db.schema.createIndex("idx_memberships_organization_id").on("memberships").column("organization_id").execute();

  await db.schema
    .createTable("teams")
    .addColumn("id", "uuid", (c) => c.primaryKey().defaultTo(sql`gen_random_uuid()`))
    .addColumn("organization_id", "uuid", (c) => c.notNull().references("organizations.id").onDelete("cascade"))
    .addColumn("name", "text", (c) => c.notNull())
    .addColumn("description", "text")
    .addColumn("created_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .addColumn("updated_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .addColumn("deleted_at", "timestamptz")
    .execute();

  await db.schema.createIndex("idx_teams_organization_id").on("teams").column("organization_id").execute();

  await db.schema
    .createTable("team_memberships")
    .addColumn("id", "uuid", (c) => c.primaryKey().defaultTo(sql`gen_random_uuid()`))
    .addColumn("team_id", "uuid", (c) => c.notNull().references("teams.id").onDelete("cascade"))
    .addColumn("user_id", "uuid", (c) => c.notNull().references("users.id").onDelete("cascade"))
    .addColumn("role", "text", (c) => c.notNull().defaultTo("member"))
    .addColumn("created_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .execute();

  await db.schema
    .createIndex("idx_team_memberships_team_user")
    .unique()
    .on("team_memberships")
    .columns(["team_id", "user_id"])
    .execute();
}

export async function down(db: Kysely<unknown>): Promise<void> {
  await db.schema.dropTable("team_memberships").ifExists().execute();
  await db.schema.dropTable("teams").ifExists().execute();
  await db.schema.dropTable("memberships").ifExists().execute();
  await db.schema.dropTable("users").ifExists().execute();
  await db.schema.dropTable("roles").ifExists().execute();
  await db.schema.dropTable("organizations").ifExists().execute();
}
