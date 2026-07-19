import { Kysely, PostgresDialect } from "kysely";
import pg from "pg";
import type { DB } from "./types.js";
import { env } from "@email-service/config";
import { logger } from "@email-service/logger";

const { Pool } = pg;

const dialect = new PostgresDialect({
  pool: new Pool({
    connectionString: env.DATABASE_URL,
    max: env.DATABASE_POOL_SIZE,
    statement_timeout: env.DATABASE_STATEMENT_TIMEOUT,
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 5000,
    application_name: "email-service",
  }),
});

export const db = new Kysely<DB>({
  dialect,
  log: (event) => {
    if (event.level === "query") {
      logger.debug({ sql: event.query.sql, params: event.query.parameters, duration: event.queryDurationMillis }, "SQL query");
    } else if (event.level === "error") {
      logger.error({ error: event.error, query: event.query?.sql }, "SQL error");
    }
  },
});

export async function closeDatabase(): Promise<void> {
  await db.destroy();
  logger.info("Database connection closed");
}

export async function checkDatabaseConnection(): Promise<boolean> {
  try {
    await db.selectFrom("organizations").select("id").limit(1).execute();
    return true;
  } catch (error) {
    logger.error({ error }, "Database connection check failed");
    return false;
  }
}

export async function runMigrations(): Promise<void> {
  logger.info("Migrations should be run via 'pnpm db:migrate' command");
}