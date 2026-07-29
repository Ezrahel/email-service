import { db, sql } from "@resendbyte/database";
import { ValidationError, NotFoundError } from "@resendbyte/errors";
import { encryptSecret, decryptSecret, generateSecureToken } from "@resendbyte/crypto";
import { addJob, QUEUE_NAMES } from "@resendbyte/queue";
import crypto from "node:crypto";

export interface CreateWebhookInput {
  url: string; events: string[]; secret?: string;
}

export interface WebhookResult {
  id: string; url: string; events: string[]; status: string; created_at: Date;
}

const PUBLIC_COLUMNS = ["id", "url", "events", "status", "failure_count", "last_success_at", "last_failure_at", "last_failure_reason", "created_at", "updated_at"] as const;

function mapToResult(row: any): WebhookResult {
  return { id: row.id, url: row.url, events: row.events, status: row.status, created_at: row.created_at };
}

export class WebhookService {
  async list(organizationId: string): Promise<WebhookResult[]> {
    const rows = await db.selectFrom("webhooks").select(PUBLIC_COLUMNS).where("organization_id", "=", organizationId).where("deleted_at", "is", null).orderBy("created_at", "desc").execute();
    return rows.map(mapToResult);
  }

  async get(organizationId: string, id: string): Promise<any> {
    const webhook = await db.selectFrom("webhooks").select([...PUBLIC_COLUMNS, "secret_ciphertext"]).where("id", "=", id).where("organization_id", "=", organizationId).where("deleted_at", "is", null).executeTakeFirst();
    if (!webhook) throw new NotFoundError("Webhook not found");
    return webhook;
  }

  async create(organizationId: string, input: CreateWebhookInput): Promise<WebhookResult> {
    if (!input.url) throw new ValidationError("URL is required");
    if (!input.events || input.events.length === 0) throw new ValidationError("At least one event is required");
    const secretCiphertext = input.secret ? encryptSecret(input.secret) : "";
    const row = await db.insertInto("webhooks").values({
      id: crypto.randomUUID(), organization_id: organizationId,
      url: input.url, events: input.events,
      secret_ciphertext: secretCiphertext,
      status: "active", failure_count: 0,
      created_at: new Date(), updated_at: new Date(),
    }).returning(PUBLIC_COLUMNS).executeTakeFirstOrThrow() as any;
    return mapToResult(row);
  }

  async delete(organizationId: string, id: string): Promise<void> {
    await db.updateTable("webhooks").set({ status: "deleted", deleted_at: new Date() }).where("id", "=", id).where("organization_id", "=", organizationId).execute();
  }

  async rotateSecret(organizationId: string, id: string): Promise<{ secret: string }> {
    await this.get(organizationId, id);
    const secret = generateSecureToken(32);
    await db.updateTable("webhooks").set({
      secret_ciphertext: encryptSecret(secret),
      updated_at: new Date(),
    }).where("id", "=", id).execute();
    return { secret };
  }

  async replay(organizationId: string, webhookId: string, deliveryId: string): Promise<void> {
    const webhook = await this.get(organizationId, webhookId);
    const delivery = await db.selectFrom("webhook_deliveries").selectAll().where("id", "=", deliveryId).where("webhook_id", "=", webhookId).executeTakeFirst();
    if (!delivery) throw new NotFoundError("Webhook delivery not found");

    const newDeliveryId = crypto.randomUUID();
    await db.insertInto("webhook_deliveries").values({
      id: newDeliveryId,
      webhook_id: webhook.id,
      event_type: delivery.event_type,
      payload: delivery.payload as any,
      attempt: 0,
      created_at: new Date(),
    }).execute();

    await addJob(QUEUE_NAMES.WEBHOOK_DELIVERY, "webhook:delivery", {
      webhookDeliveryId: newDeliveryId,
    });

    await db.updateTable("webhooks").set({
      failure_count: 0,
      updated_at: new Date(),
    }).where("id", "=", webhook.id).execute();
  }

  async getDeliveries(organizationId: string, webhookId: string, page: number = 1, perPage: number = 20): Promise<{ data: any[]; meta: { page: number; perPage: number; total: number; pages: number } }> {
    await this.get(organizationId, webhookId);
    const offset = (page - 1) * perPage;
    const [{ count }] = await db.selectFrom("webhook_deliveries").select(db.fn.countAll().as("count")).where("webhook_id", "=", webhookId).execute() as any;
    const total = Number(count);
    const data = await db.selectFrom("webhook_deliveries").selectAll().where("webhook_id", "=", webhookId).orderBy("created_at", "desc").limit(perPage).offset(offset).execute();
    return { data, meta: { page, perPage, total, pages: Math.ceil(total / perPage) } };
  }

  async dispatch(organizationId: string, eventType: string, payload: Record<string, unknown>): Promise<void> {
    const webhooks: any[] = await sql`
      SELECT * FROM "webhooks"
      WHERE "organization_id" = ${organizationId}
        AND "status" = 'active'
        AND "deleted_at" IS NULL
        AND ${eventType} = ANY("events")
      ORDER BY "created_at" DESC
    `.execute(db).then(r => r.rows);

    for (const webhook of webhooks) {
      const deliveryId = crypto.randomUUID();
      await db.insertInto("webhook_deliveries").values({
        id: deliveryId,
        webhook_id: webhook.id,
        event_type: eventType,
        payload: payload as any,
        attempt: 0,
        created_at: new Date(),
      }).execute();

      await addJob(QUEUE_NAMES.WEBHOOK_DELIVERY, "webhook:delivery", {
        webhookDeliveryId: deliveryId,
      });
    }
  }
}
