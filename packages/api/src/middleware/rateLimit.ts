import type { FastifyRequest, FastifyReply } from "fastify";
import { env } from "@email-service/config";
import { logger } from "@email-service/logger";

const rateLimitStore = new Map<string, { count: number; resetAt: number }>();

export async function rateLimitMiddleware(
  request: FastifyRequest,
  reply: FastifyReply
): Promise<void> {
  if (request.url === "/health" || request.url === "/ready") {
    return;
  }

  const key = getRateLimitKey(request);
  const now = Date.now();
  const windowMs = env.RATE_LIMIT_WINDOW_MS;
  const maxRequests = env.RATE_LIMIT_MAX_REQUESTS;

  const record = rateLimitStore.get(key);

  if (!record || now > record.resetAt) {
    rateLimitStore.set(key, { count: 1, resetAt: now + windowMs });
    setRateLimitHeaders(reply, maxRequests, maxRequests - 1, record?.resetAt ?? now + windowMs);
    return;
  }

  if (record.count >= maxRequests) {
    const retryAfter = Math.ceil((record.resetAt - now) / 1000);
    reply.header("Retry-After", retryAfter.toString());
    throw Object.assign(new Error(`Rate limit exceeded. Try again in ${retryAfter}s`), { statusCode: 429 });
  }

  record.count++;
  setRateLimitHeaders(reply, maxRequests, maxRequests - record.count, record.resetAt);
}

function getRateLimitKey(request: FastifyRequest): string {
  const ip = request.ip;
  const apiKey = (request as any).apiKey?.id;
  const userId = (request as any).user?.id;

  return apiKey ? `apikey:${apiKey}` : userId ? `user:${userId}` : `ip:${ip}`;
}

function setRateLimitHeaders(
  reply: FastifyReply,
  limit: number,
  remaining: number,
  resetAt: number
): void {
  reply.header("X-RateLimit-Limit", limit.toString());
  reply.header("X-RateLimit-Remaining", Math.max(0, remaining).toString());
  reply.header("X-RateLimit-Reset", Math.ceil(resetAt / 1000).toString());
}

setInterval(() => {
  const now = Date.now();
  for (const [key, record] of rateLimitStore.entries()) {
    if (now > record.resetAt + 60000) {
      rateLimitStore.delete(key);
    }
  }
}, 60000);

export function createRateLimiter(options: {
  max: number;
  windowMs: number;
  keyGenerator?: (req: FastifyRequest) => string;
}) {
  const store = new Map<string, { count: number; resetAt: number }>();

  return async (request: FastifyRequest, reply: FastifyReply): Promise<void> => {
    const key = options.keyGenerator
      ? options.keyGenerator(request)
      : request.ip;

    const now = Date.now();
    const record = store.get(key);

    if (!record || now > record.resetAt) {
      store.set(key, { count: 1, resetAt: now + options.windowMs });
      reply.header("X-RateLimit-Limit", options.max.toString());
      reply.header("X-RateLimit-Remaining", (options.max - 1).toString());
      return;
    }

    if (record.count >= options.max) {
      const retryAfter = Math.ceil((record.resetAt - now) / 1000);
      reply.header("Retry-After", retryAfter.toString());
      throw Object.assign(new Error(`Rate limit exceeded. Retry after ${retryAfter}s`), { statusCode: 429 });
    }

    record.count++;
    reply.header("X-RateLimit-Limit", options.max.toString());
    reply.header("X-RateLimit-Remaining", Math.max(0, options.max - record.count).toString());
  };
}