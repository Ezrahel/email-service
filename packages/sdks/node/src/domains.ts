import type { HttpClient } from "./client.js";
import type { Domain } from "./types.js";

export class DomainsResource {
  constructor(private client: HttpClient) {}

  async list(): Promise<Domain[]> {
    return this.client.get("/api/v1/domains");
  }

  async create(domain: string): Promise<Domain> {
    return this.client.post("/api/v1/domains", { domain });
  }

  async verify(id: string): Promise<void> {
    return this.client.post(`/api/v1/domains/${id}/verify`);
  }
}
