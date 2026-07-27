import type { FastifyRequest, FastifyReply } from "fastify";
import { verifyAccessToken, verifyAPIKey } from "@email-service/crypto";
import { UnauthorizedError, ForbiddenError } from "@email-service/errors";
import { logger } from "@email-service/logger";
import { db } from "@email-service/database";

export interface AuthenticatedRequest extends FastifyRequest {
  user?: {
    id: string;
    email: string;
    organizationId: string;
  };
  apiKey?: {
    id: string;
    organizationId: string;
    scopes: string[];
  };
}

export async function authMiddleware(request: FastifyRequest, reply: FastifyReply): Promise<void> {
  if (
    request.url === "/health" ||
    request.url === "/ready" ||
    request.url.startsWith("/docs") ||
    request.url.startsWith("/api/v1/auth/")
  ) {
    return;
  }

  const authHeader = request.headers.authorization;

  if (!authHeader) {
    throw new UnauthorizedError("Authorization header required");
  }

  if (authHeader.startsWith("Bearer ") && authHeader.length > 7) {
    const token = authHeader.slice(7);

    if (token.startsWith("em_")) {
      await validateAPIKey(token, request);
      return;
    }

    await validateSession(token, request);
    return;
  }

  throw new UnauthorizedError("Invalid authorization format");
}

async function validateSession(token: string, request: FastifyRequest): Promise<void> {
  try {
    const payload = await verifyAccessToken(token);
    const membership = await db
      .selectFrom("memberships")
      .select("organization_id")
      .where("user_id", "=", payload.sub)
      .where("status", "=", "active")
      .executeTakeFirst();
    (request as any).user = {
      id: payload.sub,
      email: payload.email,
      organizationId: membership?.organization_id || "",
    };
  } catch (error) {
    throw new UnauthorizedError("Invalid or expired session");
  }
}

async function validateAPIKey(key: string, request: FastifyRequest): Promise<void> {
  const prefixMatch = key.match(/^(em_[a-f0-9]{4}_)/);
  if (!prefixMatch) {
    throw new UnauthorizedError("Invalid API key format");
  }

  const prefix = prefixMatch[1]!;
  const apiKey = await db
    .selectFrom("api_keys")
    .select(["id", "organization_id", "key_digest", "key_last_chars", "scopes", "allowed_ips", "status", "expires_at"])
    .where("key_prefix", "=", prefix)
    .where("status", "=", "active")
    .where((eb) => eb.or([eb("revoked_at", "is", null), eb("revoked_at", ">", new Date())]))
    .where((eb) => eb.or([eb("expires_at", "is", null), eb("expires_at", ">", new Date())]))
    .executeTakeFirst();

  if (!apiKey) {
    throw new UnauthorizedError("Invalid API key");
  }

  if (!apiKey.key_digest) {
    throw new UnauthorizedError("Invalid API key - missing digest");
  }
  const isValid = verifyAPIKey(key, apiKey.key_digest);
  if (!isValid) {
    throw new UnauthorizedError("Invalid API key");
  }

  if (apiKey.allowed_ips && apiKey.allowed_ips.length > 0) {
    const clientIP = request.ip || "";
    const allowed = apiKey.allowed_ips.some((ip) => {
      if (ip.includes("/")) {
        const networkPrefix = ip.split("/")[0]?.split(".").slice(0, -1).join(".") || "";
        return clientIP.startsWith(networkPrefix);
      }
      return ip === clientIP;
    });

    if (!allowed) {
      throw new ForbiddenError("IP not allowed for this API key");
    }
  }

  await db
    .updateTable("api_keys")
    .set({ last_used_at: new Date() })
    .where("id", "=", apiKey.id)
    .execute();

  (request as any).apiKey = {
    id: apiKey.id,
    organizationId: apiKey.organization_id,
    scopes: apiKey.scopes || [],
  };
}

export function requireScope(...requiredScopes: string[]) {
  return async (request: FastifyRequest, reply: FastifyReply): Promise<void> => {
    await authMiddleware(request, reply);

    const apiKey = (request as any).apiKey;
    const user = (request as any).user;

    if (user) {
      if (!user.organizationId) {
        const membership = await db
          .selectFrom("memberships")
          .select("organization_id")
          .where("user_id", "=", user.id)
          .where("status", "=", "active")
          .executeTakeFirst();
        user.organizationId = membership?.organization_id || "";
      }
      if (!user.organizationId) {
        throw new UnauthorizedError("Organization context required");
      }
      (request as any).organizationId = user.organizationId;
      return;
    }

    if (!apiKey) {
      throw new ForbiddenError("API key required");
    }

    const hasScope = requiredScopes.some((scope) => apiKey.scopes.includes(scope));
    if (!hasScope) {
      throw new ForbiddenError(`Required scope: ${requiredScopes.join(" or ")}`);
    }

    (request as any).organizationId = apiKey.organizationId;
  };
}

export function requireOrganizationAccess(request: FastifyRequest, reply: FastifyReply): void {
  if (
    request.url === "/health" ||
    request.url === "/ready" ||
    request.url.startsWith("/docs") ||
    request.url.startsWith("/api/v1/auth/")
  ) {
    return;
  }

  const user = (request as any).user;
  const apiKey = (request as any).apiKey;

  if (!user && !apiKey) {
    throw new UnauthorizedError("Authentication required");
  }

  const orgId = user?.organizationId || apiKey?.organizationId;
  if (!orgId) {
    throw new UnauthorizedError("Organization context required");
  }

  (request as any).organizationId = orgId;
}