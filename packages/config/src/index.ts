import { z } from "zod";
import dotenv from "dotenv";

dotenv.config();

const envSchema = z.object({
  // Application
  NODE_ENV: z.enum(["development", "test", "production"]).default("development"),
  PORT: z.coerce.number().default(3000),
  API_PREFIX: z.string().default("/api/v1"),

  // Database
  DATABASE_URL: z.string().url().startsWith("postgresql://"),
  DATABASE_POOL_SIZE: z.coerce.number().default(10),
  DATABASE_STATEMENT_TIMEOUT: z.coerce.number().default(5000),

  // Redis
  REDIS_URL: z.string().url().startsWith("redis://"),
  REDIS_POOL_SIZE: z.coerce.number().default(15),

  // Better Auth
  BETTER_AUTH_SECRET: z.string().min(32),
  BETTER_AUTH_URL: z.string().url().default("http://localhost:3000"),
  BETTER_AUTH_TRUSTED_ORIGINS: z.string().optional(),

  // Rate Limiting
  RATE_LIMIT_WINDOW_MS: z.coerce.number().default(60000),
  RATE_LIMIT_MAX_REQUESTS: z.coerce.number().default(1000),

  // Email Providers
  SMTP_HOST: z.string().optional(),
  SMTP_PORT: z.coerce.number().optional(),
  SMTP_USER: z.string().optional(),
  SMTP_PASS: z.string().optional(),
  SMTP_FROM: z.string().email().optional(),

  SMTP_GATEWAY_PORTS: z.string().default("587,2525"),
  SMTP_TLS_KEY_PATH: z.string().optional(),
  SMTP_TLS_CERT_PATH: z.string().optional(),

  MAILGUN_API_KEY: z.string().optional(),
  MAILGUN_DOMAIN: z.string().optional(),
  MAILGUN_BASE_URL: z.string().url().optional().or(z.literal("")),

  SENDGRID_API_KEY: z.string().optional(),

  SES_REGION: z.string().optional(),
  SES_ACCESS_KEY: z.string().optional(),
  SES_SECRET_KEY: z.string().optional(),

  POSTMARK_API_KEY: z.string().optional(),

  // API Keys
  API_KEY_PREFIX: z.string().default("em_"),

  // Storage
  S3_ENDPOINT: z.string().url().optional().or(z.literal("")),
  S3_BUCKET: z.string().optional(),
  S3_ACCESS_KEY: z.string().optional(),
  S3_SECRET_KEY: z.string().optional(),
  S3_REGION: z.string().optional(),

  // Tracking
  PUBLIC_URL: z.string().url().default("http://localhost:3000"),

  // Observability
  OTEL_EXPORTER_EL_EXPORTER: z.enum(["none", "console", "otlp"]).default("none"),
  OTEL_ENDPOINT: z.string().url().optional().or(z.literal("")),
  SENTRY_DSN: z.string().url().optional().or(z.literal("")),
  SENTRY_ENVIRONMENT: z.string().optional(),
  PROMETHEUS_PORT: z.coerce.number().default(9090),

  // Feature Flags
  FF_ENABLE_ANALYTICS: z.coerce.boolean().default(true),
  FF_ENABLE_WEBHOOKS: z.coerce.boolean().default(true),
  FF_ENABLE_BATCHING: z.coerce.boolean().default(true),
  FF_ENABLE_TEMPLATES: z.coerce.boolean().default(true),
  FF_ENABLE_SMTP_GATEWAY: z.coerce.boolean().default(true),

  ENCRYPTION_KEY: z.string().min(32).optional(),

  // Billing / Paystack
  PAYSTACK_SECRET_KEY: z.string().optional(),
  PAYSTACK_PUBLIC_KEY: z.string().optional(),

  // Security
  CORS_ORIGIN: z.string().default("*"),
  IP_ALLOWLIST: z.string().optional(),
  REQUEST_TIMEOUT_MS: z.coerce.number().default(30000),
});

export type Env = z.infer<typeof envSchema>;

let cachedEnv: Env | null = null;

export function getEnv(): Env {
  if (cachedEnv) return cachedEnv;

  const result = envSchema.safeParse(process.env);

  if (!result.success) {
    const errors = result.error.flatten().fieldErrors;
    const message = Object.entries(errors)
      .map(([field, msgs]) => `${field}: ${msgs.join(", ")}`)
      .join("\n");
    throw new Error(`Invalid environment configuration:\n${message}`);
  }

  cachedEnv = result.data;
  return cachedEnv;
}

export const env: Env = getEnv();

export function isDevelopment(): boolean {
  return env.NODE_ENV === "development";
}

export function isTest(): boolean {
  return env.NODE_ENV === "test";
}

export function isProduction(): boolean {
  return env.NODE_ENV === "production";
}