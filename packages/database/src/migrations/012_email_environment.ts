import { sql, type Kysely } from "kysely";

export async function up(db: Kysely<unknown>): Promise<void> {
  await db.schema
    .alterTable("email_messages")
    .addColumn("environment", "text", (c) => c.notNull().defaultTo("live"))
    .execute();

  await db.schema
    .createIndex("idx_email_messages_environment")
    .on("email_messages")
    .column("environment")
    .execute();
}

export async function down(db: Kysely<unknown>): Promise<void> {
  await db.schema
    .alterTable("email_messages")
    .dropColumn("environment")
    .execute();
}
