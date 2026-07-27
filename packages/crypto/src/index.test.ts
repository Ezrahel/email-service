import { describe, it, expect } from "vitest";

// Functions that depend on env vars need them loaded
import {
  hashString,
  constantTimeCompare,
  generateAPIKey,
  hashAPIKey,
  verifyAPIKey,
  generateWebhookSignature,
  verifyWebhookSignature,
  generateSecureToken,
  generateIdempotencyKey,
} from "./index.js";

describe("hashString", () => {
  it("returns a consistent hash for the same input", () => {
    const result1 = hashString("hello");
    const result2 = hashString("hello");
    expect(result1).toBe(result2);
  });

  it("returns different hashes for different inputs", () => {
    const result1 = hashString("hello");
    const result2 = hashString("world");
    expect(result1).not.toBe(result2);
  });

  it("supports sha512 algorithm", () => {
    const sha256 = hashString("test", "sha256");
    const sha512 = hashString("test", "sha512");
    expect(sha256).not.toBe(sha512);
    expect(sha512.length).toBe(128);
  });

  it("returns a 64-character hex string for sha256", () => {
    const result = hashString("anything");
    expect(result).toMatch(/^[a-f0-9]{64}$/);
  });
});

describe("constantTimeCompare", () => {
  it("returns true for equal strings", () => {
    expect(constantTimeCompare("abc", "abc")).toBe(true);
  });

  it("returns false for different strings of same length", () => {
    expect(constantTimeCompare("abc", "abd")).toBe(false);
  });

  it("returns false for different lengths", () => {
    expect(constantTimeCompare("abc", "abcd")).toBe(false);
  });

  it("returns false for empty vs non-empty", () => {
    expect(constantTimeCompare("", "a")).toBe(false);
  });

  it("returns true for empty strings", () => {
    expect(constantTimeCompare("", "")).toBe(true);
  });
});

describe("hashAPIKey", () => {
  it("returns a sha256 hex digest", () => {
    const result = hashAPIKey("test-key-123");
    expect(result).toMatch(/^[a-f0-9]{64}$/);
  });

  it("is deterministic", () => {
    expect(hashAPIKey("key")).toBe(hashAPIKey("key"));
  });
});

describe("verifyAPIKey", () => {
  it("returns true for a valid key", () => {
    const key = "em_a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6";
    const digest = hashAPIKey(key);
    expect(verifyAPIKey(key, digest)).toBe(true);
  });

  it("returns false for an invalid key", () => {
    const key = "em_a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6";
    const digest = hashAPIKey(key);
    expect(verifyAPIKey(key + "x", digest)).toBe(false);
  });
});

describe("generateAPIKey", () => {
  it("returns a key with the configured prefix", () => {
    const result = generateAPIKey();
    expect(result.fullKey).toMatch(/^em_/);
    expect(result.prefix).toMatch(/^em_/);
  });

  it("returns prefix ending with underscore", () => {
    const result = generateAPIKey();
    expect(result.prefix).toMatch(/_$/);
  });

  it("returns lastChars matching last 4 chars of fullKey", () => {
    const result = generateAPIKey();
    expect(result.fullKey.slice(-4)).toBe(result.lastChars);
  });

  it("digest is a sha256 of fullKey", () => {
    const result = generateAPIKey();
    const expectedDigest = hashString(result.fullKey);
    expect(result.digest).toBe(expectedDigest);
  });
});

describe("generateWebhookSignature / verifyWebhookSignature", () => {
  it("generates a verifiable signature", () => {
    const payload = JSON.stringify({ event: "email.delivered", id: "123" });
    const secret = "whsec_test_secret_key_123";
    const signature = generateWebhookSignature(payload, secret);
    expect(signature).toMatch(/^[a-f0-9]{64}$/);
    expect(verifyWebhookSignature(payload, secret, signature)).toBe(true);
  });

  it("fails verification with wrong secret", () => {
    const payload = JSON.stringify({ event: "email.delivered" });
    const signature = generateWebhookSignature(payload, "secret1");
    expect(verifyWebhookSignature(payload, "secret2", signature)).toBe(false);
  });

  it("fails verification with wrong payload", () => {
    const payload = JSON.stringify({ event: "email.delivered" });
    const signature = generateWebhookSignature(payload, "secret");
    expect(verifyWebhookSignature(JSON.stringify({ event: "email.bounced" }), "secret", signature)).toBe(false);
  });
});

describe("generateSecureToken", () => {
  it("returns a hex string of the specified length in bytes", () => {
    const token = generateSecureToken(16);
    expect(token).toMatch(/^[a-f0-9]{32}$/);
  });

  it("defaults to 32 bytes (64 hex chars)", () => {
    const token = generateSecureToken();
    expect(token).toMatch(/^[a-f0-9]{64}$/);
  });

  it("generates unique tokens", () => {
    const token1 = generateSecureToken();
    const token2 = generateSecureToken();
    expect(token1).not.toBe(token2);
  });
});

describe("generateIdempotencyKey", () => {
  it("starts with idem_ prefix", () => {
    const key = generateIdempotencyKey();
    expect(key).toMatch(/^idem_/);
  });

  it("generates unique keys", () => {
    const key1 = generateIdempotencyKey();
    const key2 = generateIdempotencyKey();
    expect(key1).not.toBe(key2);
  });
});
