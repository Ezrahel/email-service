import { db } from "@email-service/database";
import { ValidationError } from "@email-service/errors";
import crypto from "node:crypto";

export interface CreateWebhookInput {
  url: string; events: string[]; secret?: string;
}

export interface WebhookResult {
  id: string; url: string; events: string[]; status: string; created_at: Date;
}

export class WebhookService {
  async list(organizationId: string): Promise<WebhookResult[]> {
    return db.selectFrom("webhooks").selectAll().where("organization_id", "=", organizationId).where("deleted_at", "is", null).orderBy("created_at", "desc").execute();
  }

  async create(organizationId: string, input: CreateWebhookInput): Promise<WebhookResult> {
    if (!input.url) throw new ValidationError("URL is required");
    if (!input.events || input.events.length === 0) throw new ValidationError("At least one event is required");
    return db.insertInto("webhooks").values({
      id: crypto.randomUUID(), organization_id: organizationId,
      url: input.url, events: input.events,
      secret_ciphertext: input.secret ? `encrypted_${input.secret}` : "",
      status: "active", failure_count: 0,
      created_at: new Date(), updated_at: new Date(),
    }).returningAll().executeTakeFirstOrThrow();
  }

  async delete(organizationId: string, id: string): Promise<void> {
    await db.updateTable("webhooks").set({ status: "deleted", deleted_at: new Date() }).where("id", "=", id).where("organization_id", "=", organizationId).execute();
  }
}
