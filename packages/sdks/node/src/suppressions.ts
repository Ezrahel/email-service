import type { HttpClient } from "./client.js";
import type { Suppression, PaginatedResponse } from "./types.js";

export class SuppressionsResource {
  constructor(private client: HttpClient) {}

  async list(params?: { page?: number; perPage?: number; reason?: string }): Promise<PaginatedResponse<Suppression>> {
    const searchParams = new URLSearchParams();
    if (params?.page) searchParams.set("page", String(params.page));
    if (params?.perPage) searchParams.set("perPage", String(params.perPage));
    if (params?.reason) searchParams.set("reason", params.reason);
    const qs = searchParams.toString();
    return this.client.get(`/api/v1/suppressions${qs ? `?${qs}` : ""}`);
  }

  async add(email: string, reason?: string): Promise<Suppression> {
    return this.client.post("/api/v1/suppressions", { email, reason: reason || "manual" });
  }

  async remove(id: string): Promise<void> {
    return this.client.delete(`/api/v1/suppressions/${id}`);
  }
}
