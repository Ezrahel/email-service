import { betterAuth, type BetterAuthPlugin } from "better-auth";
import { kyselyAdapter } from "@better-auth/kysely-adapter";
import { env } from "@resendbyte/config";
import { logger } from "@resendbyte/logger";
import { db } from "@resendbyte/database";
import { hashPassword, verifyPassword } from "@resendbyte/crypto";
import { fromNodeHeaders, toNodeHandler } from "better-auth/node";
import type { FastifyRequest, FastifyReply } from "fastify";

const plugins: BetterAuthPlugin[] = [];

export const auth = betterAuth({
  baseURL: env.BETTER_AUTH_URL,
  secret: env.BETTER_AUTH_SECRET,
  trustedOrigins: env.BETTER_AUTH_TRUSTED_ORIGINS?.split(",") || [],
  database: kyselyAdapter(db, { type: "postgres" }),
  emailAndPassword: {
    enabled: true,
    requireEmailVerification: true,
    autoSignIn: true,
    password: {
      hash: (password: string) => hashPassword(password),
      verify: ({ hash, password }: { hash: string; password: string }) => verifyPassword(password, hash),
    },
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
  plugins,
  logger: {
    log: (message) => logger.debug({ message }, "Better Auth"),
    error: (message: string, error: Error) => logger.error({ message, error }, "Better Auth Error"),
  },
});

const rawAuthHandler = toNodeHandler(auth);

export async function handleAuth(request: FastifyRequest, reply: FastifyReply): Promise<void> {
  const raw = request.raw;
  const canReadRaw = !raw.destroyed && raw.readableEnded !== true && raw.readable;

  if (canReadRaw) {
    await rawAuthHandler(raw, reply.raw);
    return;
  }

  const method = request.method;
  const proto = (request.headers["x-forwarded-proto"] as string) || ((raw.socket as any).encrypted ? "https" : "http");
  const host = (request.headers.host as string) || "localhost";
  const base = `${proto}://${host}`;

  let body: ReadableStream<Uint8Array> | undefined;
  if (method !== "GET" && method !== "HEAD" && request.body !== undefined) {
    const content = typeof request.body === "string" ? request.body : JSON.stringify(request.body);
    body = new ReadableStream({
      start(controller) {
        controller.enqueue(new TextEncoder().encode(content));
        controller.close();
      },
    });
  }

  const webReq = new Request(`${base}${request.url}`, {
    method,
    headers: fromNodeHeaders(raw.headers),
    body,
    duplex: "half",
  } as RequestInit);

  const response = await auth.handler(webReq);

  const setCookies = typeof response.headers.getSetCookie === "function" ? response.headers.getSetCookie() : [];
  response.headers.forEach((value, key) => {
    if (key.toLowerCase() === "set-cookie") return;
    try {
      reply.raw.setHeader(key, value);
    } catch {
      // ignore invalid headers
    }
  });
  if (setCookies.length > 0) {
    reply.raw.setHeader("set-cookie", setCookies);
  }

  reply.raw.statusCode = response.status;
  reply.raw.writeHead(response.status);

  const reader = response.body?.getReader();
  if (!reader) {
    reply.raw.end();
    return;
  }
  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    reply.raw.write(Buffer.from(value));
  }
  reply.raw.end();
}
