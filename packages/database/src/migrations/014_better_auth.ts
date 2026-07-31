import { sql, type Kysely } from "kysely";

export async function up(db: Kysely<unknown>): Promise<void> {
  await db.schema
    .createTable("user")
    .addColumn("id", "text", (c) => c.primaryKey())
    .addColumn("name", "text", (c) => c.notNull())
    .addColumn("email", "text", (c) => c.notNull().unique())
    .addColumn("emailVerified", "boolean", (c) => c.notNull().defaultTo(false))
    .addColumn("image", "text")
    .addColumn("createdAt", "timestamptz", (c) => c.notNull())
    .addColumn("updatedAt", "timestamptz", (c) => c.notNull())
    .addColumn("organizationId", "text")
    .addColumn("firstName", "text")
    .addColumn("lastName", "text")
    .addColumn("timezone", "text", (c) => c.notNull().defaultTo("UTC"))
    .addColumn("locale", "text", (c) => c.notNull().defaultTo("en"))
    .execute();

  await db.schema
    .createTable("session")
    .addColumn("id", "text", (c) => c.primaryKey())
    .addColumn("expiresAt", "timestamptz", (c) => c.notNull())
    .addColumn("token", "text", (c) => c.notNull().unique())
    .addColumn("createdAt", "timestamptz", (c) => c.notNull())
    .addColumn("updatedAt", "timestamptz", (c) => c.notNull())
    .addColumn("ipAddress", "text")
    .addColumn("userAgent", "text")
    .addColumn("userId", "text", (c) => c.notNull().references("user.id").onDelete("cascade"))
    .execute();

  await db.schema
    .createTable("account")
    .addColumn("id", "text", (c) => c.primaryKey())
    .addColumn("accountId", "text", (c) => c.notNull())
    .addColumn("providerId", "text", (c) => c.notNull())
    .addColumn("userId", "text", (c) => c.notNull().references("user.id").onDelete("cascade"))
    .addColumn("accessToken", "text")
    .addColumn("refreshToken", "text")
    .addColumn("idToken", "text")
    .addColumn("accessTokenExpiresAt", "timestamptz")
    .addColumn("refreshTokenExpiresAt", "timestamptz")
    .addColumn("scope", "text")
    .addColumn("password", "text")
    .addColumn("createdAt", "timestamptz", (c) => c.notNull())
    .addColumn("updatedAt", "timestamptz", (c) => c.notNull())
    .execute();

  await db.schema
    .createTable("verification")
    .addColumn("id", "text", (c) => c.primaryKey())
    .addColumn("identifier", "text", (c) => c.notNull())
    .addColumn("value", "text", (c) => c.notNull())
    .addColumn("expiresAt", "timestamptz", (c) => c.notNull())
    .addColumn("createdAt", "timestamptz", (c) => c.notNull())
    .addColumn("updatedAt", "timestamptz", (c) => c.notNull())
    .execute();

  await db.schema.createIndex("idx_session_user_id").on("session").column("userId").execute();
  await db.schema.createIndex("idx_session_token").on("session").column("token").execute();
  await db.schema.createIndex("idx_account_user_id").on("account").column("userId").execute();
  await db.schema.createIndex("idx_account_provider").on("account").columns(["accountId", "providerId"]).execute();
  await db.schema.createIndex("idx_user_email").on("user").column("email").execute();
  await db.schema.createIndex("idx_verification_identifier").on("verification").column("identifier").execute();
}

export async function down(db: Kysely<unknown>): Promise<void> {
  await db.schema.dropTable("verification").ifExists().execute();
  await db.schema.dropTable("account").ifExists().execute();
  await db.schema.dropTable("session").ifExists().execute();
  await db.schema.dropTable("user").ifExists().execute();
}
