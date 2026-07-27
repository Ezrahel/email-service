import { sql, type Kysely } from "kysely";

export async function up(db: Kysely<unknown>): Promise<void> {
  await db.schema
    .createTable("email_metrics")
    .addColumn("id", "uuid", (c) => c.primaryKey().defaultTo(sql`gen_random_uuid()`))
    .addColumn("email_message_id", "uuid", (c) => c.notNull().references("email_messages.id").onDelete("cascade"))
    .addColumn("delivery_id", "uuid", (c) => c.references("deliveries.id").onDelete("set null"))
    .addColumn("is_delivered", "boolean", (c) => c.notNull().defaultTo(false))
    .addColumn("is_opened", "boolean", (c) => c.notNull().defaultTo(false))
    .addColumn("is_clicked", "boolean", (c) => c.notNull().defaultTo(false))
    .addColumn("is_bounced", "boolean", (c) => c.notNull().defaultTo(false))
    .addColumn("is_complained", "boolean", (c) => c.notNull().defaultTo(false))
    .addColumn("is_unsubscribed", "boolean", (c) => c.notNull().defaultTo(false))
    .addColumn("opened_at", "timestamptz")
    .addColumn("clicked_at", "timestamptz")
    .addColumn("bounced_at", "timestamptz")
    .addColumn("complained_at", "timestamptz")
    .addColumn("unsubscribed_at", "timestamptz")
    .addColumn("open_count", "integer", (c) => c.notNull().defaultTo(0))
    .addColumn("click_count", "integer", (c) => c.notNull().defaultTo(0))
    .addColumn("user_agent", "text")
    .addColumn("ip_address", "text")
    .addColumn("country", "text")
    .addColumn("device", "text")
    .addColumn("browser", "text")
    .addColumn("os", "text")
    .addColumn("created_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .addColumn("updated_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .execute();

  await db.schema
    .createIndex("idx_email_metrics_email_message_id")
    .unique()
    .on("email_metrics")
    .column("email_message_id")
    .execute();
  await db.schema.createIndex("idx_email_metrics_delivery_id").on("email_metrics").column("delivery_id").execute();

  await db.schema
    .createTable("aggregates")
    .addColumn("id", "uuid", (c) => c.primaryKey().defaultTo(sql`gen_random_uuid()`))
    .addColumn("organization_id", "uuid", (c) => c.notNull().references("organizations.id").onDelete("cascade"))
    .addColumn("metric_name", "text", (c) => c.notNull())
    .addColumn("granularity", "text", (c) => c.notNull())
    .addColumn("bucket", "timestamptz", (c) => c.notNull())
    .addColumn("total_count", "integer", (c) => c.notNull().defaultTo(0))
    .addColumn("delivered_count", "integer", (c) => c.notNull().defaultTo(0))
    .addColumn("failed_count", "integer", (c) => c.notNull().defaultTo(0))
    .addColumn("bounced_count", "integer", (c) => c.notNull().defaultTo(0))
    .addColumn("opened_count", "integer", (c) => c.notNull().defaultTo(0))
    .addColumn("clicked_count", "integer", (c) => c.notNull().defaultTo(0))
    .addColumn("complained_count", "integer", (c) => c.notNull().defaultTo(0))
    .addColumn("queued_count", "integer", (c) => c.notNull().defaultTo(0))
    .addColumn("delivery_rate", "float8")
    .addColumn("open_rate", "float8")
    .addColumn("click_rate", "float8")
    .addColumn("bounce_rate", "float8")
    .addColumn("complaint_rate", "float8")
    .addColumn("avg_delivery_latency_ms", "integer")
    .addColumn("p50_latency_ms", "integer")
    .addColumn("p90_latency_ms", "integer")
    .addColumn("p99_latency_ms", "integer")
    .addColumn("created_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .addColumn("updated_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .execute();

  await db.schema
    .createIndex("idx_aggregates_org_metric_bucket")
    .unique()
    .on("aggregates")
    .columns(["organization_id", "metric_name", "granularity", "bucket"])
    .execute();

  await db.schema
    .createTable("usage_records")
    .addColumn("id", "uuid", (c) => c.primaryKey().defaultTo(sql`gen_random_uuid()`))
    .addColumn("organization_id", "uuid", (c) => c.notNull().references("organizations.id").onDelete("cascade"))
    .addColumn("metric_name", "text", (c) => c.notNull())
    .addColumn("period_start", "timestamptz", (c) => c.notNull())
    .addColumn("period_end", "timestamptz", (c) => c.notNull())
    .addColumn("count", "integer", (c) => c.notNull().defaultTo(0))
    .addColumn("metadata", "jsonb", (c) => c.notNull().defaultTo(sql`'{}'::jsonb`))
    .addColumn("created_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .execute();

  await db.schema
    .createIndex("idx_usage_records_org_metric_period")
    .unique()
    .on("usage_records")
    .columns(["organization_id", "metric_name", "period_start"])
    .execute();

  await db.schema
    .createTable("provider_costs")
    .addColumn("id", "uuid", (c) => c.primaryKey().defaultTo(sql`gen_random_uuid()`))
    .addColumn("organization_id", "uuid", (c) => c.notNull().references("organizations.id").onDelete("cascade"))
    .addColumn("provider_type", "text", (c) => c.notNull())
    .addColumn("date", "date", (c) => c.notNull())
    .addColumn("emails_sent", "integer", (c) => c.notNull().defaultTo(0))
    .addColumn("cost_cents", "integer", (c) => c.notNull().defaultTo(0))
    .addColumn("currency", "text", (c) => c.notNull().defaultTo("USD"))
    .addColumn("created_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .addColumn("updated_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .execute();

  await db.schema
    .createIndex("idx_provider_costs_org_provider_date")
    .unique()
    .on("provider_costs")
    .columns(["organization_id", "provider_type", "date"])
    .execute();

  const rollupColumns = (
    t: ReturnType<Kysely<unknown>["schema"]["createTable"]>
  ): ReturnType<typeof t.addColumn> => t;

  for (const table of ["rollup_1m", "rollup_5m"] as const) {
    await db.schema
      .createTable(table)
      .addColumn("id", "uuid", (c) => c.primaryKey().defaultTo(sql`gen_random_uuid()`))
      .addColumn("organization_id", "uuid", (c) => c.notNull().references("organizations.id").onDelete("cascade"))
      .addColumn("metric", "text", (c) => c.notNull())
      .addColumn("bucket", "timestamptz", (c) => c.notNull())
      .addColumn("count", "integer", (c) => c.notNull().defaultTo(0))
      .addColumn("error_count", "integer", (c) => c.notNull().defaultTo(0))
      .addColumn("latency_avg", "float8")
      .addColumn("latency_p50", "float8")
      .addColumn("latency_p90", "float8")
      .addColumn("latency_p99", "float8")
      .addColumn("created_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
      .addColumn("updated_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
      .execute();

    await db.schema
      .createIndex(`idx_${table}_org_metric_bucket`)
      .unique()
      .on(table)
      .columns(["organization_id", "metric", "bucket"])
      .execute();
  }

  await db.schema
    .createTable("rollup_daily_domain")
    .addColumn("id", "uuid", (c) => c.primaryKey().defaultTo(sql`gen_random_uuid()`))
    .addColumn("organization_id", "uuid", (c) => c.notNull().references("organizations.id").onDelete("cascade"))
    .addColumn("domain_id", "uuid", (c) => c.references("domains.id").onDelete("set null"))
    .addColumn("date", "date", (c) => c.notNull())
    .addColumn("total_sent", "integer", (c) => c.notNull().defaultTo(0))
    .addColumn("delivered", "integer", (c) => c.notNull().defaultTo(0))
    .addColumn("bounced", "integer", (c) => c.notNull().defaultTo(0))
    .addColumn("complained", "integer", (c) => c.notNull().defaultTo(0))
    .addColumn("opened", "integer", (c) => c.notNull().defaultTo(0))
    .addColumn("clicked", "integer", (c) => c.notNull().defaultTo(0))
    .addColumn("created_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .addColumn("updated_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .execute();

  await db.schema
    .createIndex("idx_rollup_daily_domain_org_date")
    .unique()
    .on("rollup_daily_domain")
    .columns(["organization_id", "domain_id", "date"])
    .execute();
}

export async function down(db: Kysely<unknown>): Promise<void> {
  await db.schema.dropTable("rollup_daily_domain").ifExists().execute();
  await db.schema.dropTable("rollup_5m").ifExists().execute();
  await db.schema.dropTable("rollup_1m").ifExists().execute();
  await db.schema.dropTable("provider_costs").ifExists().execute();
  await db.schema.dropTable("usage_records").ifExists().execute();
  await db.schema.dropTable("aggregates").ifExists().execute();
  await db.schema.dropTable("email_metrics").ifExists().execute();
}
