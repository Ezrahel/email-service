import { sql, type Kysely } from "kysely";

export async function up(db: Kysely<unknown>): Promise<void> {
  await sql`ALTER TABLE "attachments" ALTER COLUMN "email_message_id" DROP NOT NULL`.execute(db);
}

export async function down(db: Kysely<unknown>): Promise<void> {
  await sql`ALTER TABLE "attachments" ALTER COLUMN "email_message_id" SET NOT NULL`.execute(db);
}
