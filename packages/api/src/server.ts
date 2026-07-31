import Fastify from "fastify";
import type { FastifyInstance, FastifyRequest, FastifyReply } from "fastify";
import cors from "@fastify/cors";
import helmet from "@fastify/helmet";
import rateLimit from "@fastify/rate-limit";
import compress from "@fastify/compress";
import multipart from "@fastify/multipart";
import swagger from "@fastify/swagger";
import swaggerUI from "@fastify/swagger-ui";
import { env } from "@resendbyte/config";
import { logger } from "@resendbyte/logger";
import { db, closeDatabase, checkDatabaseConnection } from "@resendbyte/database";
import { closeQueueConnections } from "@resendbyte/queue";
import { initTelemetry, shutdownTelemetry } from "@resendbyte/telemetry";
import {
  ApplicationError,
  NotFoundError,
  toApplicationError,
} from "@resendbyte/errors";
import { handleAuth } from "./auth.js";
import { registerRoutes } from "./routes/index.js";
import { trackingRoutes } from "./routes/tracking.js";
import { startSmtpServer, stopSmtpServer } from "@resendbyte/smtp-gateway";
import { getMetricsAsText } from "@resendbyte/telemetry";
import { auditResponseHandler } from "./middleware/audit.js";

const authHandler = handleAuth;

declare module "fastify" {
  interface FastifyRequest {
    startTime: number;
  }
}

async function buildServer(): Promise<FastifyInstance> {
  const server = Fastify({
    logger: false,
    ajv: { customOptions: { removeAdditional: "all" } },
  });

  await server.register(cors, {
    origin: env.CORS_ORIGIN,
    credentials: true,
    methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
  });

  await server.register(helmet, {
    contentSecurityPolicy: false,
  });

  await server.register(rateLimit, {
    max: env.RATE_LIMIT_MAX_REQUESTS,
    timeWindow: env.RATE_LIMIT_WINDOW_MS,
    allowList: env.IP_ALLOWLIST?.split(",").filter(Boolean),
    keyGenerator: (req: FastifyRequest) => req.ip,
  });

  await server.register(compress, { global: true, threshold: 1024 });

  await server.register(multipart, {
    limits: { fileSize: 25 * 1024 * 1024, files: 10 },
    throwFileSizeLimit: false,
  });

  await server.register(swagger, {
    openapi: {
      info: {
        title: "Email Service API",
        description: "Transactional email delivery platform API",
        version: "0.2.0",
      },
      servers: [{ url: `http://localhost:${env.PORT}${env.API_PREFIX}`, description: "Development" }],
      components: {
        securitySchemes: {
          bearerAuth: { type: "http", scheme: "bearer", bearerFormat: "JWT" },
          apiKeyAuth: { type: "apiKey", in: "header", name: "Authorization", description: "Bearer <api_key>" },
        },
      },
    },
  });

  await server.register(swaggerUI, {
    routePrefix: "/docs",
    uiConfig: { docExpansion: "list", deepLinking: true },
  });

  server.setErrorHandler(async (error, request, reply) => {
    const appError = toApplicationError(error);

    const logLevel = appError.status >= 500 ? "error" : "warn";
    logger[logLevel](
      { error: appError.message, code: appError.code, status: appError.status, path: request.url, method: request.method },
      "Request error"
    );

    reply.status(appError.status).send(appError.toResponse());
  });

  server.setNotFoundHandler(async (request, reply) => {
    throw new NotFoundError("Route", request.url);
  });

  server.addHook("onRequest", async (request, reply) => {
    request.startTime = Date.now();
    const reqId = request.headers["x-request-id"];
    request.id = Array.isArray(reqId) ? (reqId[0] || crypto.randomUUID()) : (reqId || crypto.randomUUID());
    reply.header("x-request-id", request.id);
  });

  server.addHook("onResponse", async (request, reply) => {
    const duration = Date.now() - (request.startTime || Date.now());
    logger.info(
      { method: request.method, url: request.url, status: reply.statusCode, duration, orgId: (request as any).organizationId },
      "Request completed"
    );
    await auditResponseHandler(request, reply);
  });

  server.get("/metrics", async (_request, reply) => {
    const metrics = await getMetricsAsText();
    reply.header("Content-Type", "text/plain; charset=utf-8").send(metrics);
  });

  server.get("/health", async () => {
    const dbHealthy = await checkDatabaseConnection();
    return {
      status: dbHealthy ? "healthy" : "degraded",
      timestamp: new Date().toISOString(),
      version: "0.2.0",
      checks: { database: dbHealthy },
    };
  });

  server.get("/ready", async () => {
    const dbHealthy = await checkDatabaseConnection();
    if (!dbHealthy) throw new Error("Database not ready");
    return { ready: true };
  });

  await server.register(trackingRoutes);
  await server.register(registerRoutes, { prefix: env.API_PREFIX });

  server.all("/api/auth/*", async (request, reply) => {
    reply.hijack();
    await authHandler(request, reply);
  });

  return server;
}

async function start() {
  try {
    initTelemetry();

    const server = await buildServer();
    await server.listen({ port: env.PORT, host: "0.0.0.0" });

    logger.info(`Server listening on port ${env.PORT}`);
    logger.info(`API docs available at http://localhost:${env.PORT}/docs`);
    logger.info(`Health check at http://localhost:${env.PORT}/health`);

    if (env.FF_ENABLE_SMTP_GATEWAY !== false) {
      try {
        await startSmtpServer();
      } catch (error) {
        logger.warn({ error }, "Failed to start SMTP gateway — continuing without it");
      }
    }

    const signals = ["SIGTERM", "SIGINT"];
    for (const signal of signals) {
      process.on(signal, async () => {
        logger.info({ signal }, "Shutting down...");
        await shutdown();
        process.exit(0);
      });
    }
  } catch (error) {
    logger.error({ error }, "Failed to start server");
    process.exit(1);
  }
}

async function shutdown(): Promise<void> {
  logger.info("Shutting down gracefully...");
  await Promise.all([closeDatabase(), closeQueueConnections(), shutdownTelemetry(), stopSmtpServer()]);
  logger.info("Shutdown complete");
}

start();