import { describe, it, expect, vi, beforeEach } from "vitest";

const mockCryptoUUID = "00000000-0000-0000-0000-000000000001";
vi.mock("node:crypto", () => ({
  default: { randomUUID: () => mockCryptoUUID },
}));

const mockDb = vi.hoisted(() => {
  const chainTarget: Record<string, any> = {};

  const handlers: Record<string, any> = {
    execute: vi.fn(),
    executeTakeFirst: vi.fn(),
    executeTakeFirstOrThrow: vi.fn(),
  };

  const makeChain = (): any =>
    new Proxy(chainTarget, {
      get(_, prop) {
        if (prop in handlers) return handlers[prop as string];
        return () => makeChain();
      },
    });

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

import { DomainService } from "../DomainService.js";

describe("DomainService", () => {
  let service: DomainService;

  beforeEach(() => {
    service = new DomainService();
    vi.clearAllMocks();
  });

  describe("list", () => {
    it("returns domains for an organization", async () => {
      const expected = [{ id: "1", domain: "example.com", organization_id: "org-1" }];
      mockDb.execute.mockResolvedValue(expected);

      const result = await service.list("org-1");

      expect(mockDb.selectFrom).toHaveBeenCalledWith("domains");
      expect(result).toEqual(expected);
    });
  });

  describe("create", () => {
    it("creates and returns a new domain", async () => {
      mockDb.executeTakeFirst.mockResolvedValue(undefined);
      mockDb.executeTakeFirstOrThrow.mockResolvedValue({
        id: mockCryptoUUID,
        organization_id: "org-1",
        domain: "example.com",
        status: "pending",
      });

      const result = await service.create("org-1", "example.com");

      expect(result.id).toBe(mockCryptoUUID);
    });

    it("throws on invalid domain format", async () => {
      await expect(service.create("org-1", "not-a-domain")).rejects.toThrow("Invalid domain format");
    });

    it("throws on duplicate domain", async () => {
      mockDb.executeTakeFirst.mockResolvedValue({ id: "existing" });

      await expect(service.create("org-1", "example.com")).rejects.toThrow("Domain already exists");
    });
  });

  describe("get", () => {
    it("returns a domain by id", async () => {
      const expected = { id: "d-1", domain: "example.com" };
      mockDb.executeTakeFirst.mockResolvedValue(expected);

      const result = await service.get("org-1", "d-1");

      expect(result).toEqual(expected);
    });

    it("throws NotFoundError when domain does not exist", async () => {
      mockDb.executeTakeFirst.mockResolvedValue(undefined);

      await expect(service.get("org-1", "missing")).rejects.toThrow("Domain");
    });
  });
});
