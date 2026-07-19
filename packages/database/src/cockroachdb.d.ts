declare module "cockroachdb" {
  import { Pool as PgPool, PoolConfig } from "pg";

  export interface PoolConfig extends PoolConfig {
    application_name?: string;
  }

  export class Pool extends PgPool {
    constructor(config?: PoolConfig);
  }

  export { Client, QueryResult, QueryResultRow } from "pg";
  export * from "pg";
}