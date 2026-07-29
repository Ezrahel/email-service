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

vi.mock("@resendbyte/crypto", () => ({
  verifyPassword: vi.fn(),
  generateAccessToken: vi.fn(),
  generateRefreshToken: vi.fn(),
  verifyRefreshToken: vi.fn(),
  generateAPIKey: vi.fn(),
}));

import { AuthService } from "../AuthService.js";
import * as crypto from "@resendbyte/crypto";

describe("AuthService", () => {
  let service: AuthService;

  beforeEach(() => {
    service = new AuthService();
    vi.clearAllMocks();
  });

  describe("login", () => {
    it("returns a LoginResult on valid credentials", async () => {
      const mockUser = {
        id: "user-1",
        email: "test@example.com",
        first_name: "Test",
        last_name: "User",
        password_hash: "hash",
        status: "active",
      };
      mockDb.executeTakeFirst
        .mockResolvedValueOnce(mockUser)
        .mockResolvedValueOnce(undefined);
      vi.mocked(crypto.verifyPassword).mockResolvedValueOnce(true);
      vi.mocked(crypto.generateAccessToken).mockResolvedValueOnce({ token: "access-token", expiresAt: new Date("2026-01-01") });
      vi.mocked(crypto.generateRefreshToken).mockResolvedValueOnce({ token: "refresh-token", expiresAt: new Date("2026-01-08") });

      const result = await service.login("test@example.com", "password123");

      expect(result.token).toBe("access-token");
      expect(result.user.email).toBe("test@example.com");
      expect(result.user.organizationId).toBeNull();
    });

    it("throws UnauthorizedError on wrong password", async () => {
      mockDb.executeTakeFirst.mockResolvedValueOnce({
        id: "user-1",
        email: "test@example.com",
        password_hash: "hash",
        status: "active",
      });
      vi.mocked(crypto.verifyPassword).mockResolvedValueOnce(false);

      await expect(service.login("test@example.com", "wrong")).rejects.toThrow("Invalid email or password");
    });

    it("throws UnauthorizedError on unknown email", async () => {
      mockDb.executeTakeFirst.mockResolvedValueOnce(undefined);

      await expect(service.login("unknown@example.com", "password123")).rejects.toThrow("Invalid email or password");
    });

    it("throws ForbiddenError on locked account", async () => {
      mockDb.executeTakeFirst.mockResolvedValueOnce({
        id: "user-1",
        email: "locked@example.com",
        password_hash: "hash",
        status: "locked",
      });
      vi.mocked(crypto.verifyPassword).mockResolvedValueOnce(true);

      await expect(service.login("locked@example.com", "password123")).rejects.toThrow("Account locked");
    });
  });

  describe("createAPIKey", () => {
    it("creates an API key and returns the result", async () => {
      vi.mocked(crypto.generateAPIKey).mockReturnValueOnce({
        prefix: "em_abcd_",
        fullKey: "em_abcd1234",
        digest: "digest123",
        lastChars: "1234",
      });
      mockDb.execute.mockResolvedValueOnce(undefined);

      const result = await service.createAPIKey("org-1", "user-1", "My Key", ["email:send"]);

      expect(result.key).toBe("em_abcd1234");
      expect(result.name).toBe("My Key");
      expect(mockDb.insertInto).toHaveBeenCalledWith("api_keys");
    });
  });

  describe("listAPIKeys", () => {
    it("returns API keys for the organization", async () => {
      const expected = [{ id: "k-1", name: "Key 1" }];
      mockDb.execute.mockResolvedValueOnce(expected);

      const result = await service.listAPIKeys("org-1");

      expect(result).toEqual(expected);
    });
  });

  describe("revokeAPIKey", () => {
    it("updates the key status to revoked", async () => {
      mockDb.execute.mockResolvedValueOnce(undefined);

      await service.revokeAPIKey("org-1", "k-1");

      expect(mockDb.updateTable).toHaveBeenCalledWith("api_keys");
    });
  });
});
