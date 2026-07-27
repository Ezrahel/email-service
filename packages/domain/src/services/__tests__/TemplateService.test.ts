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
    ...handlers,
  };
});

vi.mock("@email-service/database", () => ({
  db: mockDb,
}));

import { TemplateService } from "../TemplateService.js";

describe("TemplateService", () => {
  let service: TemplateService;

  beforeEach(() => {
    service = new TemplateService();
    vi.clearAllMocks();
  });

  describe("list", () => {
    it("returns paginated templates", async () => {
      const templates = [{ id: "t-1", name: "Welcome" }];
      mockDb.execute.mockResolvedValue(templates);
      mockDb.executeTakeFirstOrThrow.mockResolvedValue({ count: 1 });

      const result = await service.list("org-1", 1, 10);

      expect(result.data).toEqual(templates);
      expect(result.total).toBe(1);
      expect(result.pages).toBe(1);
    });
  });

  describe("create", () => {
    it("creates a template and initial version", async () => {
      mockDb.executeTakeFirstOrThrow.mockResolvedValue({
        id: mockCryptoUUID,
        name: "Welcome",
        slug: "welcome",
        created_at: new Date(),
      });
      mockDb.execute.mockResolvedValue(undefined);

      const result = await service.create("org-1", {
        name: "Welcome",
        subject: "Hello",
        htmlBody: "<p>Hi</p>",
      });

      expect(result.id).toBe(mockCryptoUUID);
      expect(result.name).toBe("Welcome");
    });
  });

  describe("get", () => {
    it("returns template with versions", async () => {
      mockDb.executeTakeFirst.mockResolvedValue({ id: "t-1", name: "Welcome" });
      mockDb.execute.mockResolvedValue([{ version: 1, subject: "Hello" }]);

      const result = await service.get("org-1", "t-1");

      expect(result.name).toBe("Welcome");
      expect(result.versions).toHaveLength(1);
    });

    it("throws NotFoundError for missing template", async () => {
      mockDb.executeTakeFirst.mockResolvedValue(undefined);

      await expect(service.get("org-1", "missing")).rejects.toThrow("Template");
    });
  });
});
