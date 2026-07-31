import { Queue, type QueueOptions, Job, type JobsOptions, Worker, type WorkerOptions, JobScheduler } from "bullmq";
import { env } from "@resendbyte/config";
import { logger } from "@resendbyte/logger";
import { InternalError } from "@resendbyte/errors";

const connection = {
  host: new URL(env.REDIS_URL).hostname,
  port: parseInt(new URL(env.REDIS_URL).port || "6379"),
  password: new URL(env.REDIS_URL).password || undefined,
  maxRetriesPerRequest: 3,
  retryStrategy: (times: number) => Math.min(times * 100, 3000),
  enableReadyCheck: true,
  lazyConnect: true,
};

export const QUEUE_NAMES = {
  EMAIL_CRITICAL: "email-critical",
  EMAIL_HIGH: "email-high",
  EMAIL_DEFAULT: "email-default",
  EMAIL_LOW: "email-low",
  EMAIL_SCHEDULED: "email-scheduled",
  DELIVERY_RETRY: "delivery-retry",
  WEBHOOK_DELIVERY: "webhook-delivery",
  WEBHOOK_RETRY: "webhook-retry",
  ANALYTICS: "analytics",
  MAINTENANCE: "maintenance",
} as const;

export type QueueName = (typeof QUEUE_NAMES)[keyof typeof QUEUE_NAMES];

interface BaseJobData {
  idempotencyKey?: string;
  priority?: number;
  delay?: number;
  attempts?: number;
  backoff?: { type: "exponential" | "fixed"; delay: number };
}

export interface EmailSubmissionJob extends BaseJobData {
  emailMessageId: string;
  organizationId: string;
  environment?: string;
}

export interface EmailBatchJob extends BaseJobData {
  batchId: string;
  organizationId: string;
  emailMessageIds: string[];
}

export interface EmailRetryJob extends BaseJobData {
  emailMessageId: string;
  retryCount: number;
}

export interface DeliveryProcessJob extends BaseJobData {
  deliveryId: string;
  providerConfigId: string;
}

export interface DeliveryRetryJob extends BaseJobData {
  deliveryId: string;
  retryCount: number;
}

export interface WebhookDeliveryJob extends BaseJobData {
  webhookDeliveryId: string;
}

export interface WebhookRetryJob extends BaseJobData {
  webhookDeliveryId: string;
  retryCount: number;
}

export interface AnalyticsRollupJob extends BaseJobData {
  organizationId: string;
  granularity: "1m" | "5m" | "1h" | "1d";
  date: string;
}

export interface MaintenanceJob extends BaseJobData {
  task: "partition_management" | "cleanup" | "materialized_view_refresh" | "retention";
}

export interface DomainVerificationJob extends BaseJobData {
  domainId: string;
  organizationId: string;
}

export type JobData =
  | EmailSubmissionJob
  | EmailBatchJob
  | EmailRetryJob
  | DeliveryProcessJob
  | DeliveryRetryJob
  | WebhookDeliveryJob
  | WebhookRetryJob
  | AnalyticsRollupJob
  | MaintenanceJob
  | DomainVerificationJob;

const queueOptions: QueueOptions = {
  connection,
  defaultJobOptions: {
    removeOnComplete: { count: 1000, age: 86400 },
    removeOnFail: { count: 5000, age: 604800 },
  },
};

const queues = new Map<QueueName, Queue>();

export function getQueue(name: QueueName): Queue {
  if (!queues.has(name)) {
    queues.set(name, new Queue(name, queueOptions));
  }
  return queues.get(name)!;
}

export function getAllQueues(): Queue[] {
  return Array.from(queues.values());
}

export async function addJob<T extends JobData>(
  queueName: QueueName,
  jobName: string,
  data: T,
  options?: Partial<QueueOptions["defaultJobOptions"]>
): Promise<Job<T>> {
  const queue = getQueue(queueName);
  return queue.add(jobName, data, options);
}

export async function addBulkJobs<T extends JobData>(
  queueName: QueueName,
  jobs: Array<{ name: string; data: T; opts?: JobsOptions }>
): Promise<Job<T>[]> {
  const queue = getQueue(queueName);
  return queue.addBulk(
    jobs.map((j) => ({ name: j.name, data: j.data, opts: j.opts }))
  );
}

export function createWorker<T extends JobData>(
  queueName: QueueName,
  processor: (job: Job<T>) => Promise<void>,
  options?: Partial<WorkerOptions>
): Worker<T> {
  const worker = new Worker<T>(queueName, processor, {
    connection,
    concurrency: options?.concurrency || 10,
    limiter: options?.limiter,
    lockDuration: options?.lockDuration || 300000,
    stalledInterval: options?.stalledInterval || 30000,
    maxStalledCount: options?.maxStalledCount || 2,
    ...options,
  });

  worker.on("completed", (job) => {
    logger.debug({ jobId: job.id, queue: queueName }, "Job completed");
  });

  worker.on("failed", (job, error) => {
    logger.error({ jobId: job?.id, queue: queueName, error }, "Job failed");
  });

  worker.on("stalled", (jobId) => {
    logger.warn({ jobId, queue: queueName }, "Job stalled");
  });

  worker.on("error", (error) => {
    logger.error({ queue: queueName, error }, "Worker error");
  });

  return worker;
}

function createRateLimiter(max: number, durationMs: number) {
  return {
    max,
    duration: durationMs,
  };
}

export const emailRateLimiter = createRateLimiter(1000, 60000);
export const webhookRateLimiter = createRateLimiter(100, 60000);
export const analyticsRateLimiter = createRateLimiter(10, 60000);

export function createScheduler(
  queueName: QueueName,
  options?: { interval?: number; lockDuration?: number }
): JobScheduler {
  return new JobScheduler(queueName, {
    connection,
  });
}

export async function closeAllQueues(): Promise<void> {
  await Promise.all(Array.from(queues.values()).map((q) => q.close()));
}

export async function pauseQueue(queueName: QueueName): Promise<void> {
  const queue = getQueue(queueName);
  await queue.pause();
}

export async function resumeQueue(queueName: QueueName): Promise<void> {
  const queue = getQueue(queueName);
  await queue.resume();
}

export async function getQueueStats(queueName: QueueName): Promise<{
  waiting: number;
  active: number;
  completed: number;
  failed: number;
  delayed: number;
  paused: boolean;
}> {
  const queue = getQueue(queueName);
  const [waiting, active, completed, failed, delayed, paused] = await Promise.all([
    queue.getWaitingCount(),
    queue.getActiveCount(),
    queue.getCompletedCount(),
    queue.getFailedCount(),
    queue.getDelayedCount(),
    queue.isPaused(),
  ]);
  return { waiting, active, completed, failed, delayed, paused };
}

export async function cleanQueue(queueName: QueueName, graceMs: number = 86400000): Promise<void> {
  const queue = getQueue(queueName);
  await queue.clean(graceMs, 1000, "completed");
  await queue.clean(graceMs, 1000, "failed");
}

export async function drainQueue(queueName: QueueName): Promise<void> {
  const queue = getQueue(queueName);
  await queue.drain(true);
}

export async function closeQueueConnections(): Promise<void> {
  await closeAllQueues();
}