import pino, { type Logger, type LoggerOptions, type DestinationStream } from "pino";
import { env } from "@email-service/config";

const isDevelopment = env.NODE_ENV === "development";
const isTest = env.NODE_ENV === "test";

const pinoOptions: LoggerOptions = {
  level: env.NODE_ENV === "production" ? "info" : "debug",
  formatters: {
    level: (label) => ({ level: label }),
    bindings: () => ({ pid: process.pid, hostname: env.NODE_ENV }),
  },
  timestamp: () => `,"timestamp":"${new Date().toISOString()}"`,
  redact: {
    paths: [
      "*.password",
      "*.password_hash",
      "*.api_key",
      "*.secret",
      "*.token",
      "*.authorization",
      "*.cookie",
      "req.headers.authorization",
      "req.headers.cookie",
      "res.headers['set-cookie']",
    ],
    censor: "[REDACTED]",
  },
  serializers: {
    err: pino.stdSerializers.err,
    req: (req) => ({
      id: req.id,
      method: req.method,
      url: req.url,
      query: req.query,
      params: req.params,
      headers: {
        "user-agent": req.headers["user-agent"],
        "content-type": req.headers["content-type"],
        "content-length": req.headers["content-length"],
      },
    }),
    res: (res) => ({
      statusCode: res.statusCode,
    }),
  },
};

let destination: DestinationStream;

if (isDevelopment) {
  destination = pino.destination({ dest: 1, sync: false, minLength: 4096 });
  // Use pino-pretty for development
  const pretty = await import("pino-pretty");
  Object.assign(destination, pretty.default({ colorize: true, translateTime: "SYS:standard", ignore: "pid,hostname" }));
} else if (isTest) {
  destination = pino.destination({ dest: "/dev/null", sync: true });
} else {
  destination = pino.destination({ dest: 1, sync: false, minLength: 4096 });
}

export const logger = pino(pinoOptions, destination);

export function createChildLogger(bindings: Record<string, unknown>): Logger {
  return logger.child(bindings);
}

export function createRequestLogger(requestId: string, userId?: string, organizationId?: string): Logger {
  return logger.child({
    requestId,
    userId,
    organizationId,
  });
}

export function createServiceLogger(serviceName: string): Logger {
  return logger.child({ service: serviceName });
}

export function createQueueLogger(queueName: string, jobId?: string): Logger {
  return logger.child({ queue: queueName, jobId });
}

export function createProviderLogger(providerName: string): Logger {
  return logger.child({ provider: providerName });
}

export function createDomainLogger(domain: string): Logger {
  return logger.child({ domain });
}

export default logger;