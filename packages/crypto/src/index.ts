import { betterAuth } from "better-auth";
import { env } from "@email-service/config";
import { logger } from "@email-service/logger";
import crypto from "crypto";

export const auth = betterAuth({
  baseURL: env.BETTER_AUTH_URL,
  secret: env.BETTER_AUTH_SECRET,
  trustedOrigins: env.BETTER_AUTH_TRUSTED_ORIGINS?.split(",") || [],
  emailAndPassword: {
    enabled: true,
    requireEmailVerification: true,
    autoSignIn: true,
  },
  session: {
    expiresIn: 60 * 60 * 24 * 7,
    updateAge: 60 * 60 * 24,
  },
  user: {
    additionalFields: {
      organizationId: { type: "string", required: false },
      firstName: { type: "string", required: false },
      lastName: { type: "string", required: false },
      timezone: { type: "string", default: "UTC", required: false },
      locale: { type: "string", default: "en", required: false },
    },
  },
  plugins: [],
  logger: {
    log: (message) => logger.debug({ message }, "Better Auth"),
    error: (message: string, error: Error) => logger.error({ message, error }, "Better Auth Error"),
  },
});

export async function verifyPassword(password: string, hash: string): Promise<boolean> {
  const bcrypt = await import("bcryptjs");
  return bcrypt.compare(password, hash);
}

export async function hashPassword(password: string): Promise<string> {
  const bcrypt = await import("bcryptjs");
  return bcrypt.hash(password, 12);
}

export function generateAPIKey(): { prefix: string; fullKey: string; digest: string; lastChars: string } {
  const randomPart = crypto.randomBytes(24).toString("hex");
  const fullKey = `${env.API_KEY_PREFIX}${randomPart}`;
  const prefix = `${env.API_KEY_PREFIX}${randomPart.slice(0, 4)}_`;
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

export function generateWebhookSignature(payload: string, secret: string): string {
  return crypto.createHash("sha256").update(secret + "." + payload).digest("hex");
}

export function verifyWebhookSignature(payload: string, secret: string, signature: string): boolean {
  const expected = crypto.createHash("sha256").update(secret + "." + payload).digest("hex");
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
  return { sub: payload.sub as string, email: payload["email"] as string };
}

export async function verifyRefreshToken(token: string): Promise<{ sub: string; email?: string }> {
  const { payload } = await jwtVerify(token, JWT_SECRET);
  return { sub: payload.sub as string, email: payload["email"] as string | undefined };
}

export type { Session, User } from "better-auth";