import type { SendEmailMessage, ProviderAdapterConfig, ProviderResponse } from "@email-service/types";
import type { ProviderType } from "@email-service/types";

export interface ProviderAdapter {
  readonly type: ProviderType;
  readonly name: string;
  send(message: SendEmailMessage, config: ProviderAdapterConfig): Promise<ProviderResponse>;
  validateConfig(config: ProviderAdapterConfig): Promise<boolean>;
  healthCheck(config: ProviderAdapterConfig): Promise<{ healthy: boolean; latency: number }>;
}

export abstract class BaseProviderAdapter implements ProviderAdapter {
  abstract readonly type: ProviderType;
  abstract readonly name: string;

  abstract send(message: SendEmailMessage, config: ProviderAdapterConfig): Promise<ProviderResponse>;
  abstract validateConfig(config: ProviderAdapterConfig): Promise<boolean>;
  abstract healthCheck(config: ProviderAdapterConfig): Promise<{ healthy: boolean; latency: number }>;

  protected abstract buildRequest(message: SendEmailMessage, config: ProviderAdapterConfig): any;
  protected abstract parseResponse(response: any): ProviderResponse;

  protected validateEmail(message: SendEmailMessage): void {
    if (!message.from || !message.from.email) {
      throw new Error("From email is required");
    }
    if (!message.to || (Array.isArray(message.to) && message.to.length === 0)) {
      throw new Error("At least one recipient is required");
    }
    if (!message.subject) {
      throw new Error("Subject is required");
    }
    if (!message.html && !message.text) {
      throw new Error("Either HTML or text body is required");
    }
  }

  protected generateMessageId(): string {
    return `<${Date.now()}.${Math.random().toString(36).substring(2, 15)}@email-service>`;
  }

  protected formatEmailAddresses(emails: Array<{ email: string; name?: string }>): string {
    return emails
      .map((e) => (e.name ? `"${e.name}" <${e.email}>` : e.email))
      .join(", ");
  }
}