import { Resource } from "@opentelemetry/resources";
import { SemanticResourceAttributes } from "@opentelemetry/semantic-conventions";
import { Registry, Counter, Gauge, Histogram, Summary } from "prom-client";
import { env } from "@email-service/config";
import { logger } from "@email-service/logger";

const registry = new Registry();

export interface TelemetryConfig {
  serviceName: string;
  serviceVersion: string;
  environment: string;
  otlpEndpoint?: string;
  prometheusPort?: number;
  enableAutoInstrumentation: boolean;
}

export const telemetryConfig = {
  serviceName: "email-service",
  serviceVersion: process.env["npm_package_version"] ?? "0.2.0",
  environment: env.NODE_ENV,
  otlpEndpoint: env.OTEL_ENDPOINT,
  prometheusPort: 9090,
  enableAutoInstrumentation: env.NODE_ENV !== "test",
};

function createResource(): Resource {
  return new Resource({
    [SemanticResourceAttributes.SERVICE_NAME]: "email-service",
    [SemanticResourceAttributes.SERVICE_VERSION]: process.env["npm_package_version"] ?? "0.2.0",
    [SemanticResourceAttributes.DEPLOYMENT_ENVIRONMENT]: env.NODE_ENV,
  });
}

export async function initTelemetry(): Promise<void> {
  logger.info("Telemetry initialized");
}

export async function shutdownTelemetry(): Promise<void> {
  logger.info("Telemetry shut down");
}

export function getMeter(name: string) {
  throw new Error("Telemetry not initialized. Call initTelemetry() first.");
}

export const metrics = {
  counter: (name: string, help: string, labelNames: string[] = []) =>
    new Counter({ name, help, labelNames, registers: [registry] }),

  gauge: (name: string, help: string, labelNames: string[] = []) =>
    new Gauge({ name, help, labelNames, registers: [registry] }),

  histogram: (name: string, help: string, labelNames: string[] = [], buckets?: number[]) =>
    new Histogram({ name, help, labelNames, buckets: buckets ?? [0.1, 0.5, 1, 2, 5, 10, 30, 60], registers: [registry] }),

  summary: (name: string, help: string, labelNames: string[] = [], percentiles: number[] = [0.5, 0.9, 0.99]) =>
    new Summary({ name, help, labelNames, percentiles, registers: [registry] }),
};

export const httpMetrics = {
  requestsTotal: metrics.counter("http_requests_total", "Total HTTP requests", ["method", "route", "status_code"]),
  requestDuration: metrics.histogram("http_request_duration_seconds", "HTTP request duration", ["method", "route"]),
  requestSize: metrics.histogram("http_request_size_bytes", "HTTP request size", ["method", "route"]),
  responseSize: metrics.histogram("http_response_size_bytes", "HTTP response size", ["method", "route"]),
};

export const queueMetrics = {
  jobsWaiting: metrics.gauge("queue_jobs_waiting", "Jobs waiting in queue", ["queue"]),
  jobsActive: metrics.gauge("queue_jobs_active", "Jobs currently processing", ["queue"]),
  jobsCompleted: metrics.counter("queue_jobs_completed_total", "Completed jobs", ["queue"]),
  jobsFailed: metrics.counter("queue_jobs_failed_total", "Failed jobs", ["queue", "error_type"]),
  jobDuration: metrics.histogram("queue_job_duration_seconds", "Job processing duration", ["queue", "job_type"]),
  queueLag: metrics.gauge("queue_lag_seconds", "Queue lag", ["queue"]),
};

export const emailMetrics = {
  sent: metrics.counter("email_sent_total", "Emails sent", ["organization_id", "provider", "status"]),
  deliveryDuration: metrics.histogram("email_delivery_duration_seconds", "Email delivery duration", ["provider"]),
  providerLatency: metrics.histogram("email_provider_latency_seconds", "Provider API latency", ["provider", "operation"]),
  bounces: metrics.counter("email_bounces_total", "Email bounces", ["organization_id", "bounce_type"]),
  complaints: metrics.counter("email_complaints_total", "Spam complaints", ["organization_id"]),
  opens: metrics.counter("email_opens_total", "Email opens", ["organization_id"]),
  clicks: metrics.counter("email_clicks_total", "Email clicks", ["organization_id"]),
};

export const authMetrics = {
  loginAttempts: metrics.counter("auth_login_attempts_total", "Login attempts", ["method", "success"]),
  tokenIssued: metrics.counter("auth_tokens_issued_total", "Tokens issued", ["type"]),
  tokenRefresh: metrics.counter("auth_tokens_refreshed_total", "Tokens refreshed", ["success"]),
  apiKeyValidations: metrics.counter("auth_apikey_validations_total", "API key validations", ["success"]),
  rateLimitHits: metrics.counter("auth_rate_limit_hits_total", "Rate limit hits", ["identifier_type"]),
};

export const dbMetrics = {
  queryDuration: metrics.histogram("db_query_duration_seconds", "Database query duration", ["operation", "table"]),
  queryErrors: metrics.counter("db_query_errors_total", "Database query errors", ["operation", "table", "error_type"]),
  poolUsage: metrics.gauge("db_pool_usage", "Database connection pool usage"),
  poolWaiters: metrics.gauge("db_pool_waiters", "Database pool waiters"),
};

export const cacheMetrics = {
  hits: metrics.counter("cache_hits_total", "Cache hits", ["cache_type"]),
  misses: metrics.counter("cache_misses_total", "Cache misses", ["cache_type"]),
  errors: metrics.counter("cache_errors_total", "Cache errors", ["cache_type", "operation"]),
  latency: metrics.histogram("cache_latency_seconds", "Cache operation latency", ["cache_type", "operation"]),
};

export const providerMetrics = {
  requests: metrics.counter("provider_requests_total", "Provider API requests", ["provider", "operation", "status"]),
  latency: metrics.histogram("provider_latency_seconds", "Provider API latency", ["provider", "operation"]),
  errors: metrics.counter("provider_errors_total", "Provider errors", ["provider", "error_type"]),
  retries: metrics.counter("provider_retries_total", "Provider retries", ["provider", "operation"]),
  rateLimited: metrics.counter("provider_rate_limited_total", "Provider rate limited", ["provider"]),
};

export function getMetricsRegistry() {
  return registry;
}

export async function getMetricsAsText(): Promise<string> {
  return registry.metrics();
}

export async function getMetricsAsJSON(): Promise<unknown> {
  return registry.getMetricsAsJSON();
}