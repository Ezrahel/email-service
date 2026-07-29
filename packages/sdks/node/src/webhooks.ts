import type { HttpClient } from "./client.js";
import type { Webhook, WebhookDelivery, CreateWebhookOptions, PaginatedResponse } from "./types.js";

export class WebhooksResource {
  constructor(private client: HttpClient) {}

  async list(): Promise<Webhook[]> {
    return this.client.get("/api/v1/webhooks");
  }

  async create(options: CreateWebhookOptions): Promise<Webhook> {
    return this.client.post("/api/v1/webhooks", options);
  }

  async delete(id: string): Promise<void> {
    return this.client.delete(`/api/v1/webhooks/${id}`);
  }

  async rotateSecret(id: string): Promise<{ secret: string }> {
    return this.client.post(`/api/v1/webhooks/${id}/rotate-secret`);
  }

  async getDeliveries(id: string, params?: { page?: number; perPage?: number }): Promise<PaginatedResponse<WebhookDelivery>> {
    const searchParams = new URLSearchParams();
    if (params?.page) searchParams.set("page", String(params.page));
    if (params?.perPage) searchParams.set("perPage", String(params.perPage));
    const qs = searchParams.toString();
    return this.client.get(`/api/v1/webhooks/${id}/deliveries${qs ? `?${qs}` : ""}`);
  }

  async replay(id: string, deliveryId: string): Promise<void> {
    return this.client.post(`/api/v1/webhooks/${id}/replay/${deliveryId}`);
  }
}
