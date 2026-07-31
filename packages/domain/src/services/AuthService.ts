import { db } from "@resendbyte/database";
import { logger } from "@resendbyte/logger";
import { UnauthorizedError, ForbiddenError, NotFoundError, ConflictError } from "@resendbyte/errors";
import { generateAccessToken, generateRefreshToken, verifyRefreshToken as verifyRefresh, verifyPassword, generateAPIKey } from "@resendbyte/crypto";
import crypto from "node:crypto";

export interface LoginResult {
  token: string;
  refreshToken: string;
  expiresAt: Date;
  user: { id: string; email: string; firstName: string; lastName: string; organizationId: string | null };
}

export interface APIKeyResult {
  key: string;
  name: string;
  scopes: string[];
  expiresAt: string | null;
}

export class AuthService {
  async login(email: string, password: string): Promise<LoginResult> {
    const user = await db.selectFrom("users").selectAll().where("email", "=", email).where("status", "=", "active").executeTakeFirst();
    if (!user || !(await verifyPassword(password, user.password_hash))) {
      logger.warn({ email }, "Failed login attempt");
      throw new UnauthorizedError("Invalid email or password");
    }
    if (user.status === "locked") throw new ForbiddenError("Account locked");

    const { token, expiresAt } = await generateAccessToken(user.id, user.email);
    const { token: refreshToken } = await generateRefreshToken(user.id);
    const membership = await db.selectFrom("memberships").select(["organization_id", "role_id"]).where("user_id", "=", user.id).where("status", "=", "active").executeTakeFirst();

    return { token, refreshToken, expiresAt, user: { id: user.id, email: user.email, firstName: user.first_name, lastName: user.last_name, organizationId: membership?.organization_id ?? null } };
  }

  async refresh(refreshToken: string): Promise<{ token: string; refreshToken: string; expiresAt: Date }> {
    let payload;
    try {
      payload = await verifyRefresh(refreshToken);
    } catch {
      throw new UnauthorizedError("Invalid or expired refresh token");
    }
    if (!payload) throw new UnauthorizedError("Invalid or expired refresh token");
    const { token, expiresAt } = await generateAccessToken(payload.sub, payload.email || "");
    const { token: newRefreshToken } = await generateRefreshToken(payload.sub);
    return { token, refreshToken: newRefreshToken, expiresAt };
  }

  async createAPIKey(organizationId: string, userId: string | undefined, name: string, scopes: string[], expiresAt?: string, allowedIPs?: string[], environment?: string): Promise<APIKeyResult> {
    const { prefix, fullKey, digest, lastChars } = generateAPIKey(environment);
    await db.insertInto("api_keys").values({
      id: crypto.randomUUID(), organization_id: organizationId, user_id: userId ?? null,
      name, key_prefix: prefix!, key_digest: digest!, key_last_chars: lastChars!,
      scopes, allowed_ips: allowedIPs || [], status: "active",
      expires_at: expiresAt ? new Date(expiresAt) : null,
      created_at: new Date(), updated_at: new Date(),
    }).execute();
    return { key: fullKey, name, scopes, expiresAt: expiresAt ?? null };
  }

  async listAPIKeys(organizationId: string): Promise<any[]> {
    return db.selectFrom("api_keys").select(["id", "name", "key_prefix", "key_last_chars", "scopes", "status", "expires_at", "last_used_at", "created_at"]).where("organization_id", "=", organizationId).where("deleted_at", "is", null).orderBy("created_at", "desc").execute();
  }

  async revokeAPIKey(organizationId: string, id: string): Promise<void> {
    await db.updateTable("api_keys").set({ status: "revoked", revoked_at: new Date() }).where("id", "=", id).where("organization_id", "=", organizationId).execute();
  }
}
