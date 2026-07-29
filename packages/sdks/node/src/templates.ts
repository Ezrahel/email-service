import type { HttpClient } from "./client.js";
import type { Template, PaginatedResponse } from "./types.js";

export class TemplatesResource {
  constructor(private client: HttpClient) {}

  async list(params?: { page?: number; perPage?: number }): Promise<PaginatedResponse<Template>> {
    const searchParams = new URLSearchParams();
    if (params?.page) searchParams.set("page", String(params.page));
    if (params?.perPage) searchParams.set("perPage", String(params.perPage));
    const qs = searchParams.toString();
    return this.client.get(`/api/v1/templates${qs ? `?${qs}` : ""}`);
  }

  async create(data: { name: string; subject: string; htmlBody: string; textBody?: string }): Promise<Template> {
    return this.client.post("/api/v1/templates", data);
  }

  async get(id: string): Promise<Template> {
    return this.client.get(`/api/v1/templates/${id}`);
  }
}
