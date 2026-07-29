import type { FastifyRequest, FastifyReply } from "fastify";

export function createRateLimiter(options: {
  max: number;
  windowMs: number;
  keyGenerator?: (req: FastifyRequest) => string;
}) {
  const store = new Map<string, { count: number; resetAt: number }>();

  return async (request: FastifyRequest, reply: FastifyReply): Promise<void> => {
    const key = options.keyGenerator ? options.keyGenerator(request) : request.ip;
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
