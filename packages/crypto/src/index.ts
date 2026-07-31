import { env } from "@resendbyte/config";
import { logger } from "@resendbyte/logger";
import crypto from "crypto";

export async function verifyPassword(password: string, hash: string): Promise<boolean> {
  const bcrypt = await import("bcryptjs");
  return bcrypt.default.compare(password, hash);
}

export async function hashPassword(password: string): Promise<string> {
  const bcrypt = await import("bcryptjs");
  return bcrypt.default.hash(password, 12);
}

export function generateAPIKey(environment?: string): { prefix: string; fullKey: string; digest: string; lastChars: string } {
  const keyPrefix = environment === "sandbox" ? "sk_test_" : environment === "live" ? "sk_live_" : env.API_KEY_PREFIX;
  const randomPart = crypto.randomBytes(24).toString("hex");
  const prefix = `${keyPrefix}${randomPart.slice(0, 4)}_`;
  const fullKey = `${prefix}${randomPart.slice(4)}`;
  const digest = crypto.createHash("sha256").update(fullKey).digest("hex");
  const lastChars = fullKey.slice(-4);
  return { prefix, fullKey, digest, lastChars };
}

export function hashAPIKey(key: string): string {
  return crypto.createHash("sha256").update(key).digest("hex");
}

export function verifyAPIKey(key: string, digest: string): boolean {
  const computed = crypto.createHash("sha256").update(key).digest("hex");
  return crypto.timingSafeEqual(Buffer.from(digest, "hex"), Buffer.from(computed, "hex"));
}

export function generateIdempotencyKey(): string {
  return `idem_${crypto.randomBytes(16).toString("hex")}`;
}

export function generateWebhookSignature(payload: string, secret: string, algorithm: "sha256" | "sha512" = "sha256"): string {
  return crypto.createHmac(algorithm, secret).update(payload).digest("hex");
}

export function verifyWebhookSignature(payload: string, secret: string, signature: string, algorithm: "sha256" | "sha512" = "sha256"): boolean {
  const expected = crypto.createHmac(algorithm, secret).update(payload).digest("hex");
  if (expected.length !== signature.length) return false;
  return crypto.timingSafeEqual(Buffer.from(expected, "hex"), Buffer.from(signature, "hex"));
}

export function constantTimeCompare(a: string, b: string): boolean {
  const bufferA = Buffer.from(a);
  const bufferB = Buffer.from(b);
  if (bufferA.length !== bufferB.length) return false;
  return crypto.timingSafeEqual(bufferA, bufferB);
}

export function generateSecureToken(length: number = 32): string {
  return crypto.randomBytes(length).toString("hex");
}

export function hashString(input: string, algorithm: "sha256" | "sha512" = "sha256"): string {
  return crypto.createHash(algorithm).update(input).digest("hex");
}

function getEncryptionKey(): Buffer {
  const key = env.ENCRYPTION_KEY || env.BETTER_AUTH_SECRET;
  if (!env.ENCRYPTION_KEY) {
    logger.warn("ENCRYPTION_KEY not set, using BETTER_AUTH_SECRET as fallback for webhook secret encryption");
  }
  return Buffer.from(key.slice(0, 32), "utf-8");
}

const ALGORITHM = "aes-256-gcm";

export function encryptSecret(plaintext: string): string {
  if (!plaintext) return "";
  const key = getEncryptionKey();
  const iv = crypto.randomBytes(16);
  const cipher = crypto.createCipheriv(ALGORITHM, key, iv);
  let encrypted = cipher.update(plaintext, "utf-8", "hex");
  encrypted += cipher.final("hex");
  const tag = cipher.getAuthTag().toString("hex");
  return `${iv.toString("hex")}:${tag}:${encrypted}`;
}

export function decryptSecret(ciphertext: string): string {
  if (!ciphertext || !ciphertext.includes(":")) return ciphertext;
  try {
    const key = getEncryptionKey();
    const parts = ciphertext.split(":");
    if (parts.length !== 3) return ciphertext;
    const [ivHex, tagHex, encrypted] = parts;
    const iv = Buffer.from(ivHex!, "hex");
    const tag = Buffer.from(tagHex!, "hex");
    const decipher = crypto.createDecipheriv(ALGORITHM, key, iv);
    decipher.setAuthTag(tag);
    let decrypted = decipher.update(encrypted!, "hex", "utf-8");
    decrypted += decipher.final("utf-8");
    return decrypted;
  } catch {
    logger.error({ ciphertextLength: ciphertext.length }, "Failed to decrypt webhook secret");
    return "";
  }
}

// JWT token generation and verification
import { SignJWT, jwtVerify } from "jose";

const JWT_SECRET = new TextEncoder().encode(env.BETTER_AUTH_SECRET);

export async function generateAccessToken(userId: string, email: string): Promise<{ token: string; expiresAt: Date }> {
  const expiresAt = new Date(Date.now() + 15 * 60 * 1000); // 15 minutes
  const token = await new SignJWT({ sub: userId, email, type: "access" })
    .setProtectedHeader({ alg: "HS256" })
    .setIssuedAt()
    .setExpirationTime(expiresAt)
    .sign(JWT_SECRET);
  return { token, expiresAt };
}

export async function generateRefreshToken(userId: string, email?: string): Promise<{ token: string; expiresAt: Date }> {
  const expiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000); // 7 days
  const token = await new SignJWT({ sub: userId, type: "refresh", email })
    .setProtectedHeader({ alg: "HS256" })
    .setIssuedAt()
    .setExpirationTime(expiresAt)
    .sign(JWT_SECRET);
  return { token, expiresAt };
}

export async function verifyAccessToken(token: string): Promise<{ sub: string; email: string }> {
  const { payload } = await jwtVerify(token, JWT_SECRET);
  if (payload["type"] !== "access") {
    throw new Error("Invalid token type: expected access token");
  }
  return { sub: payload.sub as string, email: payload["email"] as string };
}

export async function verifyRefreshToken(token: string): Promise<{ sub: string; email?: string }> {
  const { payload } = await jwtVerify(token, JWT_SECRET);
  if (payload["type"] !== "refresh") {
    throw new Error("Invalid token type: expected refresh token");
  }
  return { sub: payload.sub as string, email: payload["email"] as string | undefined };
}