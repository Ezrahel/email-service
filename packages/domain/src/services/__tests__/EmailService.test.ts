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
    fn: {
      max: vi.fn(() => ({ as: vi.fn(() => "max_version") })),
    },
    selectFrom: vi.fn(() => makeChain()),
    insertInto: vi.fn(() => makeChain()),
    updateTable: vi.fn(() => makeChain()),
    deleteFrom: vi.fn(() => makeChain()),
    ...handlers,
  };
});

vi.mock("@resendbyte/database", () => ({
  db: mockDb,
  sql: (() => {
    const fn = (_strings: TemplateStringsArray, ..._values: any[]) => ({ as: vi.fn(() => ({})), execute: vi.fn() });
    return fn;
  })(),
}));

import { EmailService } from "../EmailService.js";

describe("EmailService", () => {
  let service: EmailService;

  beforeEach(() => {
    service = new EmailService();
    vi.clearAllMocks();
  });

  describe("send", () => {
    it("inserts an email message and returns queued status", async () => {
      mockDb.execute.mockResolvedValue(undefined);

      const result = await service.send("org-1", "from@example.com", "to@example.com", "Subject");

      expect(result.emailId).toBe(mockCryptoUUID);
      expect(result.status).toBe("queued");
    });
  });

  describe("sendBatch", () => {
    it("inserts all messages and returns batch info", async () => {
      mockDb.execute.mockResolvedValue(undefined);

      const result = await service.sendBatch("org-1", [
        { from: "a@b.com", to: "c@d.com", subject: "S1" },
        { from: "a@b.com", to: "e@f.com", subject: "S2" },
      ]);

      expect(result.count).toBe(2);
      expect(result.batchId).toBeDefined();
    });

    it("throws on more than 1000 messages", async () => {
      const msgs = Array.from({ length: 1001 }, (_, i) => ({
        from: "a@b.com", to: `c${i}@d.com`, subject: "S",
      }));

      await expect(service.sendBatch("org-1", msgs)).rejects.toThrow("Batch limit is 1000 messages");
    });
  });

  describe("sendFromTemplate", () => {
    it("renders template and creates email", async () => {
      mockDb.executeTakeFirst
        .mockResolvedValueOnce({ max_version: 1 })
        .mockResolvedValueOnce({
          id: "tpl-1",
          organization_id: "org-1",
          subject: "Hello {{name}}",
          html_body: "<p>Hi {{name}}</p>",
          text_body: "Hi {{name}}",
        })
        .mockResolvedValueOnce({ domain: "example.com" });
      mockDb.execute.mockResolvedValue(undefined);

      const result = await service.sendFromTemplate("org-1", "tpl-1", "user@example.com", { name: "Alice" });

      expect(result.emailId).toBe(mockCryptoUUID);
      expect(result.status).toBe("queued");
    });

    it("throws NotFoundError for missing template", async () => {
      mockDb.executeTakeFirst.mockResolvedValue(undefined);

      await expect(service.sendFromTemplate("org-1", "missing", "user@example.com")).rejects.toThrow("Template");
    });
  });

  describe("list", () => {
    it("returns paginated emails", async () => {
      const emails = [{ id: "e-1", subject: "Test" }];
      mockDb.execute.mockResolvedValue(emails);
      mockDb.executeTakeFirstOrThrow.mockResolvedValue({ count: 1 });

      const result = await service.list("org-1", { page: 1, perPage: 10 });

      expect(result.data).toEqual(emails);
      expect(result.total).toBe(1);
      expect(result.pages).toBe(1);
    });
  });

  describe("get", () => {
    it("returns email with deliveries", async () => {
      mockDb.executeTakeFirst.mockResolvedValue({ id: "e-1", subject: "Test" });
      mockDb.execute.mockResolvedValue([{ id: "d-1", status: "delivered" }]);

      const result = await service.get("org-1", "e-1");

      expect(result.subject).toBe("Test");
      expect(result.deliveries).toHaveLength(1);
    });

    it("throws NotFoundError for missing email", async () => {
      mockDb.executeTakeFirst.mockResolvedValue(undefined);

      await expect(service.get("org-1", "missing")).rejects.toThrow("Email");
    });
  });
});
