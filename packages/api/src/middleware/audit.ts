import type { FastifyRequest, FastifyReply } from "fastify";
import { AuditService } from "@resendbyte/domain";
import { logger } from "@resendbyte/logger";

const MUTATING_METHODS = new Set(["POST", "PUT", "PATCH", "DELETE"]);

const RESOURCE_FROM_PATH = [
  { prefix: "/api/v1/api-keys", resourceType: "api_key" },
  { prefix: "/api/v1/webhooks", resourceType: "webhook" },
  { prefix: "/api/v1/domains", resourceType: "domain" },
  { prefix: "/api/v1/templates", resourceType: "template" },
  { prefix: "/api/v1/suppressions", resourceType: "suppression" },
  { prefix: "/api/v1/emails", resourceType: "email" },
  { prefix: "/api/v1/billing", resourceType: "billing" },
];

function detectResource(path: string): { resourceType: string; resourceId?: string } {
  for (const rule of RESOURCE_FROM_PATH) {
    if (path.startsWith(rule.prefix)) {
      const rest = path.slice(rule.prefix.length).replace(/^\//, "");
      const parts = rest.split("/");
      const id = parts[0] && parts[0].length === 36 ? parts[0] : undefined;
      return { resourceType: rule.resourceType, resourceId: id };
    }
  }
  return { resourceType: "unknown" };
}

const SKIP_PATHS = new Set(["/api/v1/health", "/api/v1/ready", "/api/v1/auth/login", "/api/v1/auth/refresh", "/api/v1/billing/webhook/paystack"]);

export async function auditResponseHandler(request: FastifyRequest, reply: FastifyReply): Promise<void> {
  try {
    if (SKIP_PATHS.has(request.url)) return;
    if (!MUTATING_METHODS.has(request.method)) return;
    if (reply.statusCode >= 400) return;
    if (!(request as any).organizationId) return;

    const { resourceType, resourceId } = detectResource(request.url);
    const action = `${request.method === "DELETE" ? "delete" : request.method === "POST" ? "create" : "update"}_${resourceType}`;

    const auditService = new AuditService();
    await auditService.log({
      organizationId: (request as any).organizationId,
      userId: (request as any).user?.id,
      action,
      resourceType,
      resourceId,
      newValues: (request.body && typeof request.body === "object") ? request.body as Record<string, unknown> : undefined,
      ipAddress: request.ip,
      userAgent: request.headers["user-agent"] || null,
    });
  } catch (error) {
    logger.error({ error }, "Failed to write audit log");
  }
}
