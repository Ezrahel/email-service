import { sql, type Kysely } from "kysely";

export async function up(db: Kysely<unknown>): Promise<void> {
  await db.schema
    .createTable("plans")
    .addColumn("id", "uuid", (c) => c.primaryKey().defaultTo(sql`gen_random_uuid()`))
    .addColumn("name", "text", (c) => c.notNull().unique())
    .addColumn("slug", "text", (c) => c.notNull().unique())
    .addColumn("description", "text")
    .addColumn("monthly_email_limit", "integer", (c) => c.notNull())
    .addColumn("price_cents", "integer", (c) => c.notNull().defaultTo(0))
    .addColumn("overage_rate_cents", "integer", (c) => c.notNull().defaultTo(0))
    .addColumn("features", "jsonb", (c) => c.notNull().defaultTo(sql`'{}'::jsonb`))
    .addColumn("is_active", "boolean", (c) => c.notNull().defaultTo(true))
    .addColumn("sort_order", "integer", (c) => c.notNull().defaultTo(0))
    .addColumn("created_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .addColumn("updated_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .execute();

  await db.schema
    .createTable("subscriptions")
    .addColumn("id", "uuid", (c) => c.primaryKey().defaultTo(sql`gen_random_uuid()`))
    .addColumn("organization_id", "uuid", (c) => c.notNull().references("organizations.id").onDelete("cascade").unique())
    .addColumn("plan_id", "uuid", (c) => c.notNull().references("plans.id"))
    .addColumn("status", "text", (c) => c.notNull().defaultTo("active"))
    .addColumn("period_start", "timestamptz", (c) => c.notNull())
    .addColumn("period_end", "timestamptz", (c) => c.notNull())
    .addColumn("cancel_at_period_end", "boolean", (c) => c.notNull().defaultTo(false))
    .addColumn("stripe_subscription_id", "text")
    .addColumn("paystack_subscription_code", "text")
    .addColumn("paystack_authorization_code", "text")
    .addColumn("overage_balance_cents", "integer", (c) => c.notNull().defaultTo(0))
    .addColumn("created_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .addColumn("updated_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .execute();

  await db.schema
    .createIndex("idx_subscriptions_organization_id").on("subscriptions").column("organization_id").execute();
  await db.schema
    .createIndex("idx_subscriptions_status").on("subscriptions").column("status").execute();

  await db.schema
    .createTable("invoices")
    .addColumn("id", "uuid", (c) => c.primaryKey().defaultTo(sql`gen_random_uuid()`))
    .addColumn("organization_id", "uuid", (c) => c.notNull().references("organizations.id").onDelete("cascade"))
    .addColumn("subscription_id", "uuid", (c) => c.references("subscriptions.id"))
    .addColumn("amount_cents", "integer", (c) => c.notNull())
    .addColumn("currency", "text", (c) => c.notNull().defaultTo("NGN"))
    .addColumn("status", "text", (c) => c.notNull().defaultTo("pending"))
    .addColumn("description", "text")
    .addColumn("period_start", "timestamptz")
    .addColumn("period_end", "timestamptz")
    .addColumn("paid_at", "timestamptz")
    .addColumn("paystack_reference", "text")
    .addColumn("created_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .addColumn("updated_at", "timestamptz", (c) => c.notNull().defaultTo(sql`now()`))
    .execute();

  await db.schema
    .createIndex("idx_invoices_organization_id").on("invoices").column("organization_id").execute();
  await db.schema
    .createIndex("idx_invoices_status").on("invoices").column("status").execute();

  await db.schema
    .alterTable("organizations")
    .addColumn("plan_id", "uuid", (c) => c.references("plans.id"))
    .addColumn("overage_enabled", "boolean", (c) => c.notNull().defaultTo(false))
    .addColumn("suspended_at", "timestamptz")
    .execute();

  await db.schema
    .createIndex("idx_organizations_plan_id").on("organizations").column("plan_id").execute();

  const freePlanId = sql`gen_random_uuid()`;
  const proPlanId = sql`gen_random_uuid()`;

  await sql`
    INSERT INTO plans (id, name, slug, description, monthly_email_limit, price_cents, overage_rate_cents, features, sort_order) VALUES
    (${freePlanId}, 'Free', 'free', 'For small projects and testing', 1000, 0, 0, '{"custom_domain": false, "api_access": true, "team_members": 1, "analytics": "basic"}', 0),
    (${proPlanId}, 'Pro', 'pro', 'For growing businesses', 50000, 2999, 10, '{"custom_domain": true, "api_access": true, "team_members": 10, "analytics": "advanced", "dedicated_ip": false}', 1),
    ('00000000-0000-0000-0000-000000000000', 'Enterprise', 'enterprise', 'For high-volume senders', 1000000, 99999, 5, '{"custom_domain": true, "api_access": true, "team_members": -1, "analytics": "advanced", "dedicated_ip": true, "sla": true}', 2)
  `.execute(db);
}

export async function down(db: Kysely<unknown>): Promise<void> {
  await db.schema.alterTable("organizations").dropColumn("suspended_at").execute();
  await db.schema.alterTable("organizations").dropColumn("overage_enabled").execute();
  await db.schema.alterTable("organizations").dropColumn("plan_id").execute();
  await db.schema.dropTable("invoices").ifExists().execute();
  await db.schema.dropTable("subscriptions").ifExists().execute();
  await db.schema.dropTable("plans").ifExists().execute();
}
