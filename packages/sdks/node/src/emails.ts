import type { HttpClient } from "./client.js";
import type { SendEmailOptions, EmailMessage, PaginatedResponse } from "./types.js";

export class EmailsResource {
  constructor(private client: HttpClient) {}

  async send(options: SendEmailOptions): Promise<{ emailId: string; environment: string; scheduledAt?: string }> {
    return this.client.post("/api/v1/emails", {
      from: options.from,
      to: options.to,
      subject: options.subject,
      html: options.html,
      text: options.text,
      replyTo: options.replyTo,
      tags: options.tags,
      idempotencyKey: options.idempotencyKey,
      scheduledAt: options.scheduledAt,
      attachmentIds: options.attachmentIds,
    });
  }

  async sendFromTemplate(templateId: string, options: { to: string; variables?: Record<string, string> }): Promise<{ emailId: string; environment: string }> {
    return this.client.post(`/api/v1/templates/${templateId}/send`, {
      to: options.to,
      variables: options.variables,
    });
  }

  async list(params?: { page?: number; perPage?: number; status?: string; after?: string; limit?: number }): Promise<PaginatedResponse<EmailMessage>> {
    const searchParams = new URLSearchParams();
    if (params?.page) searchParams.set("page", String(params.page));
    if (params?.perPage) searchParams.set("perPage", String(params.perPage));
    if (params?.status) searchParams.set("status", params.status);
    if (params?.after) searchParams.set("after", params.after);
    if (params?.limit) searchParams.set("limit", String(params.limit));
    const qs = searchParams.toString();
    return this.client.get(`/api/v1/emails${qs ? `?${qs}` : ""}`);
  }

  async get(id: string): Promise<EmailMessage> {
    return this.client.get(`/api/v1/emails/${id}`);
  }

  async cancel(id: string): Promise<void> {
    return this.client.post(`/api/v1/emails/${id}/cancel`);
  }

  async validate(options: SendEmailOptions): Promise<{ valid: boolean }> {
    return this.client.post("/api/v1/emails/validate", options);
  }
}
