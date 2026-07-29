import { describe, it, expect, vi, beforeEach } from "vitest";

const mockCryptoUUID = "00000000-0000-0000-0000-000000000001";
vi.mock("node:crypto", () => ({
  default: { randomUUID: () => mockCryptoUUID },
}));

const mockDb = vi.hoisted(() => {
  const handlers: Record<string, any> = {
    execute: vi.fn(),
    executeTakeFirst: vi.fn(),
    executeTakeFirstOrThrow: vi.fn(),
  };

  const makeChain = (): any =>
    new Proxy(
      {},
      {
        get(_, prop) {
          if (prop in handlers) return handlers[prop as string];
          return () => makeChain();
        },
      }
    );

  return {
    selectFrom: vi.fn(() => makeChain()),
    insertInto: vi.fn(() => makeChain()),
    updateTable: vi.fn(() => makeChain()),
    deleteFrom: vi.fn(() => makeChain()),
    ...handlers,
  };
});

vi.mock("@resendbyte/database", () => ({
  db: mockDb,
}));

import { WebhookService } from "../WebhookService.js";

describe("WebhookService", () => {
  let service: WebhookService;

  beforeEach(() => {
    service = new WebhookService();
    vi.clearAllMocks();
  });

  describe("list", () => {
    it("returns webhooks for an organization", async () => {
      const expected = [{ id: "w-1", url: "https://example.com/hook", events: ["email.delivered"] }];
      mockDb.execute.mockResolvedValue(expected);

      const result = await service.list("org-1");

      expect(result).toEqual(expected);
    });
  });

  describe("create", () => {
    it("creates and returns a webhook", async () => {
      const expected = { id: mockCryptoUUID, url: "https://example.com/hook", events: ["email.delivered"], status: "active" };
      mockDb.executeTakeFirstOrThrow.mockResolvedValue(expected);

      const result = await service.create("org-1", { url: "https://example.com/hook", events: ["email.delivered"] });

      expect(result.id).toBe(mockCryptoUUID);
    });

    it("throws on missing URL", async () => {
      await expect(service.create("org-1", { url: "", events: ["email.delivered"] })).rejects.toThrow("URL is required");
    });

    it("throws on empty events", async () => {
      await expect(service.create("org-1", { url: "https://example.com/hook", events: [] })).rejects.toThrow("At least one event is required");
    });
  });

  describe("delete", () => {
    it("updates webhook status to deleted", async () => {
      mockDb.execute.mockResolvedValue(undefined);

      await service.delete("org-1", "w-1");

      expect(mockDb.updateTable).toHaveBeenCalledWith("webhooks");
    });
  });
});
