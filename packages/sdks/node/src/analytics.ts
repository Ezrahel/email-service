import type { HttpClient } from "./client.js";
import type { AnalyticsOverview } from "./types.js";

export class AnalyticsResource {
  constructor(private client: HttpClient) {}

  async getOverview(): Promise<AnalyticsOverview> {
    return this.client.get("/api/v1/analytics/overview");
  }

  async getDashboardUsage(): Promise<any> {
    return this.client.get("/api/v1/dashboard/usage");
  }

  async getDashboardActivity(): Promise<any> {
    return this.client.get("/api/v1/dashboard/activity");
  }

  async getDashboardProviders(): Promise<any> {
    return this.client.get("/api/v1/dashboard/providers");
  }
}
