import type { FastifyRequest, FastifyReply } from "fastify";
import crypto from "crypto";
import { env } from "@email-service/config";
import { logger } from "@email-service/logger";

interface ProxyOptions {
  timeout?: number;
  maxRetries?: number;
}

const DEFAULT_OPTIONS: Required<ProxyOptions> = {
  timeout: 30000,
  maxRetries: 2,
};

const HOP_BY_HOP = [
  "connection",
  "keep-alive",
  "proxy-authenticate",
  "proxy-authorization",
  "te",
  "trailers",
  "transfer-encoding",
  "upgrade",
  "host",
];

export async function proxy(
  target: string,
  request: FastifyRequest,
  reply: FastifyReply,
  options: ProxyOptions = {}
): Promise<any> {
  const opts = { ...DEFAULT_OPTIONS, ...options };
  const url = new URL(request.url, target);

  const query = request.query as Record<string, string>;
  for (const [key, value] of Object.entries(query)) {
    if (value !== undefined) url.searchParams.set(key, String(value));
  }

  const headers: Record<string, string> = {
    "x-forwarded-for": request.ip,
    "x-forwarded-proto": request.protocol,
    "x-forwarded-host": request.hostname,
    "x-request-id": request.id || crypto.randomUUID(),
    "user-agent": (request.headers["user-agent"] as string) || "",
  };

  const authHeader = request.headers["authorization"];
  if (authHeader) {
    headers["authorization"] = Array.isArray(authHeader) ? authHeader[0] : authHeader;
  }

  const apiKeyHeader = request.headers["x-api-key"];
  if (apiKeyHeader) {
    headers["x-api-key"] = Array.isArray(apiKeyHeader) ? (apiKeyHeader[0] || "") : apiKeyHeader;
  }

  for (const h of HOP_BY_HOP) {
    delete headers[h];
  }

  let lastError: Error | null = null;

  for (let attempt = 0; attempt <= opts.maxRetries; attempt++) {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), opts.timeout);

    try {
      const response = await fetch(url.toString(), {
        method: request.method,
        headers,
        body: ["GET", "HEAD"].includes(request.method) ? undefined : JSON.stringify(request.body),
        signal: controller.signal,
        redirect: "manual",
      });

      clearTimeout(timeoutId);

      const responseHeaders: Record<string, string> = {};
      response.headers.forEach((value: string, key: string) => {
        if (!HOP_BY_HOP.includes(key.toLowerCase())) {
          responseHeaders[key] = value;
        }
      });

      reply.status(response.status);
      for (const [key, value] of Object.entries(responseHeaders)) {
        reply.header(key, value);
      }

      const data = await response.text();
      return data ? JSON.parse(data) : null;
    } catch (error) {
      clearTimeout(timeoutId);
      lastError = error as Error;

      if (attempt < opts.maxRetries) {
        const delay = Math.min(100 * Math.pow(2, attempt), 1000);
        await new Promise((r) => setTimeout(r, delay));
        continue;
      }
      break;
    }
  }

  logger.error({ error: lastError, url: url.toString() }, "Proxy failed after retries");
  throw lastError || new Error("Proxy failed");
}