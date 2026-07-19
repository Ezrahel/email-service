import type { ProviderAdapterConfig, ProviderType, ProviderHealth, SendEmailMessage, ProviderResponse } from "@email-service/types";
import { SmtpAdapter } from "./SmtpAdapter.js";
import { SendGridAdapter } from "./SendGridAdapter.js";
import { MailgunAdapter } from "./MailgunAdapter.js";
import { SESAdapter } from "./SESAdapter.js";
import { PostmarkAdapter } from "./PostmarkAdapter.js";
import { type ProviderAdapter } from "./ProviderAdapter.js";
import { logger } from "@email-service/logger";

export interface ProviderRegistryOptions {
  healthCheckInterval?: number;
  failureThreshold?: number;
  cooldownPeriod?: number;
}

export interface ProviderInstance {
  adapter: ProviderAdapter;
  config: ProviderAdapterConfig;
  health: ProviderHealth;
  priority: number;
  weight: number;
}

export class ProviderRegistry {
  private providers = new Map<string, ProviderInstance[]>();
  private healthCheckInterval: number;
  private failureThreshold: number;
  private cooldownPeriod: number;
  private healthCheckTimer: ReturnType<typeof setInterval> | null = null;

  constructor(options: ProviderRegistryOptions = {}) {
    this.healthCheckInterval = options.healthCheckInterval || 60000;
    this.failureThreshold = options.failureThreshold || 3;
    this.cooldownPeriod = options.cooldownPeriod || 300000;
    this.initializeProviders();
  }

  private initializeProviders(): void {
    this.register(new SmtpAdapter(), { priority: 10, weight: 1 });
    this.register(new SendGridAdapter(), { priority: 5, weight: 3 });
    this.register(new MailgunAdapter(), { priority: 5, weight: 2 });
    this.register(new SESAdapter(), { priority: 5, weight: 2 });
    this.register(new PostmarkAdapter(), { priority: 5, weight: 2 });
  }

  register(adapter: ProviderAdapter, options: { priority: number; weight: number } = { priority: 10, weight: 1 }): void {
    const type = adapter.type;
    const instances = this.providers.get(type) || [];
    instances.push({
      adapter,
      config: {} as ProviderAdapterConfig,
      health: { healthy: true, latency: 0, lastCheck: Date.now() },
      priority: options.priority,
      weight: options.weight,
    });
    instances.sort((a, b) => a.priority - b.priority);
    this.providers.set(type, instances);
  }

  setConfig(type: ProviderType, config: ProviderAdapterConfig): void {
    const instances = this.providers.get(type);
    if (instances) {
      instances.forEach(p => { p.config = config; });
    }
  }

  async send(message: SendEmailMessage, options?: { provider?: string; fallback?: boolean }): Promise<ProviderResponse> {
    const candidates = this.selectProviders(message, options);

    for (const instance of candidates) {
      if (!instance.health.healthy) continue;

      try {
        const response = await instance.adapter.send(message, instance.config);
        this.recordSuccess(instance);
        if (response.success) return response;

        this.recordFailure(instance, response.error);
      } catch (error) {
        this.recordFailure(instance, error instanceof Error ? error.message : "Unknown error");
      }
    }

    throw new Error("All providers failed");
  }

  private selectProviders(message: SendEmailMessage, options?: { provider?: string; fallback?: boolean }): ProviderInstance[] {
    let candidates = Array.from(this.providers.values()).flat();

    if (options?.provider) {
      const filtered = candidates.filter(p => p.adapter.type === options.provider);
      if (filtered.length > 0) return filtered;
    }

    if (!options?.fallback) {
      const preferred = candidates.find(p => p.health.healthy && Object.keys(p.config).length > 0);
      return preferred ? [preferred] : [];
    }

    return candidates
      .filter(p => p.health.healthy && Object.keys(p.config).length > 0)
      .sort((a, b) => {
        if (a.priority !== b.priority) return a.priority - b.priority;
        return b.health.latency - a.health.latency;
      });
  }

  private recordSuccess(instance: ProviderInstance): void {
    instance.health.failures = 0;
    instance.health.lastSuccess = Date.now();
  }

  private recordFailure(instance: ProviderInstance, error?: string): void {
    instance.health.failures = (instance.health.failures || 0) + 1;
    instance.health.lastError = Date.now();
    if (error) {
      instance.health.lastErrorMessage = error;
    }

    if ((instance.health.failures || 0) >= this.failureThreshold) {
      instance.health.healthy = false;
      instance.health.cooldownUntil = Date.now() + this.cooldownPeriod;
      logger.warn({ provider: instance.adapter.type }, `Provider marked unhealthy after ${this.failureThreshold} failures`);
    }
  }

  startHealthChecks(): void {
    if (this.healthCheckTimer) return;
    this.healthCheckTimer = setInterval(() => this.runHealthChecks(), this.healthCheckInterval);
  }

  private async runHealthChecks(): Promise<void> {
    for (const [, instances] of this.providers) {
      for (const instance of instances) {
        if (!instance.config) continue;

        try {
          const health = await instance.adapter.healthCheck(instance.config);
          instance.health.healthy = health.healthy;
          instance.health.latency = health.latency;
          instance.health.lastCheck = Date.now();

          if (health.healthy && instance.health.cooldownUntil && Date.now() > instance.health.cooldownUntil) {
            instance.health.healthy = true;
            instance.health.failures = 0;
            delete instance.health.cooldownUntil;
          }
        } catch (error) {
          instance.health.healthy = false;
        }
      }
    }
  }

  getProviderHealth(type: ProviderType): ProviderHealth[] {
    const instances = this.providers.get(type) || [];
    return instances.map(i => i.health);
  }

  getAllProviders(): ProviderInstance[] {
    return Array.from(this.providers.values()).flat();
  }

  shutdown(): void {
    if (this.healthCheckTimer) {
      clearInterval(this.healthCheckTimer);
      this.healthCheckTimer = null;
    }
  }
}