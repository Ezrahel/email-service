import { describe, it, expect, vi, beforeEach } from "vitest";

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

vi.mock("kysely", () => ({
  sql: (() => {
    const fn = (strings: TemplateStringsArray, ...values: any[]) => ({
      execute: (executor: any) => {
        if (executor && typeof executor.execute === "function") return executor.execute();
        return Promise.resolve();
      },
    });
    return fn;
  })(),
}));

import { OrganizationService } from "../OrganizationService.js";

describe("OrganizationService", () => {
  let service: OrganizationService;

  beforeEach(() => {
    service = new OrganizationService();
    vi.clearAllMocks();
  });

  describe("getUsage", () => {
    it("returns usage stats for the current month", async () => {
      mockDb.executeTakeFirst.mockResolvedValue({
        emails_sent_this_month: 5,
        monthly_email_limit: 100000,
        month_start_date: new Date(),
      });

      const result = await service.getUsage("org-1");

      expect(result.sentThisMonth).toBe(5);
      expect(result.limit).toBe(100000);
    });

    it("returns defaults when organization is not found", async () => {
      mockDb.executeTakeFirst.mockResolvedValue(undefined);

      const result = await service.getUsage("missing-org");

      expect(result.sentThisMonth).toBe(0);
    });
  });

  describe("incrementUsage", () => {
    it("executes the update query", async () => {
      await service.incrementUsage("org-1");

      expect(mockDb.execute).toHaveBeenCalled();
    });
  });
});
