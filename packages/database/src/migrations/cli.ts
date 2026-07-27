import { readdir } from "node:fs/promises";
import { resolve, join, basename, relative } from "node:path";
import { fileURLToPath } from "node:url";
import { dirname } from "node:path";
import { Migrator, FileMigrationProvider } from "kysely";
import { db, closeDatabase } from "../index.js";
import { logger } from "@email-service/logger";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const pathModule = { resolve, join, basename, relative };

async function run() {
  const command = process.argv[2];
  if (!command || !["migrate", "rollback"].includes(command)) {
    console.error("Usage: node cli.js <migrate|rollback>");
    process.exit(1);
  }

  const migrator = new Migrator({
    db,
    provider: new FileMigrationProvider({
      fs: { readdir: (p: string) => readdir(p) as Promise<string[]> },
      path: pathModule,
      migrationFolder: resolve(__dirname),
    }),
  });

  const result = command === "migrate" ? await migrator.migrateToLatest() : await migrator.migrateDown();

  for (const r of result.results || []) {
    if (r.status === "Success") {
      logger.info({ migration: r.migrationName, direction: r.direction }, "Migration applied");
    } else if (r.status === "Error") {
      logger.error({ migration: r.migrationName }, "Migration failed");
    }
  }

  if (result.error) {
    logger.error({ error: String(result.error) }, "Migration error");
    process.exit(1);
  }

  await closeDatabase();
}

run();
