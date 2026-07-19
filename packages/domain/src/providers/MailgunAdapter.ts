import type { SendEmailMessage, ProviderAdapterConfig, ProviderResponse } from "@email-service/types";
import { BaseProviderAdapter } from "./ProviderAdapter.js";

export class MailgunAdapter extends BaseProviderAdapter {
  readonly type = "mailgun" as const;
  readonly name = "Mailgun";

  async send(message: SendEmailMessage, config: ProviderAdapterConfig): Promise<ProviderResponse> {
    this.validateEmail(message);

    const { apiKey, domain } = config;
    if (!apiKey || !domain) {
      return { success: false, error: "Mailgun API key and domain are required" };
    }

    const formData = this.buildFormData(message);

    try {
      const response = await fetch(`https://api.mailgun.net/v3/${domain}/messages`, {
        method: "POST",
        headers: {
          Authorization: `Basic ${Buffer.from(`api:${apiKey}`).toString("base64")}`,
        },
        body: formData,
      });

      const result: any = await response.json();

      if (!response.ok) {
        return {
          success: false,
          error: result.message || "Mailgun API error",
          errorCode: result.code?.toString() || response.status.toString(),
          providerResponse: result,
        };
      }

      return {
        success: true,
        messageId: result.id || this.generateMessageId(),
        providerResponse: result,
      };
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : "Unknown error",
      };
    }
  }

  async validateConfig(config: ProviderAdapterConfig): Promise<boolean> {
    return !!(config.apiKey && config.domain);
  }

  async healthCheck(config: ProviderAdapterConfig): Promise<{ healthy: boolean; latency: number }> {
    const start = Date.now();
    try {
      const response = await fetch(`https://api.mailgun.net/v3/domains/${config.domain}`, {
        headers: {
          Authorization: `Basic ${Buffer.from(`api:${config.apiKey}`).toString("base64")}`,
        },
      });
      return { healthy: response.ok, latency: Date.now() - start };
    } catch {
      return { healthy: false, latency: Date.now() - start };
    }
  }

  protected buildRequest(message: SendEmailMessage, config: ProviderAdapterConfig): any {
    return this.buildFormData(message);
  }

  protected parseResponse(response: any): ProviderResponse {
    return {
      success: true,
      messageId: response.id || this.generateMessageId(),
      providerResponse: response,
    };
  }

  private buildFormData(message: SendEmailMessage): FormData {
    const formData = new FormData();

    const from = message.from.name
      ? `"${message.from.name}" <${message.from.email}>`
      : message.from.email;
    formData.append("from", from);

    const to = Array.isArray(message.to) ? message.to : [message.to];
    to.forEach((r) => formData.append("to", r.name ? `"${r.name}" <${r.email}>` : r.email));

    if (message.cc) {
      const cc = Array.isArray(message.cc) ? message.cc : [message.cc];
      cc.forEach((r) => formData.append("cc", r.name ? `"${r.name}" <${r.email}>` : r.email));
    }

    if (message.bcc) {
      const bcc = Array.isArray(message.bcc) ? message.bcc : [message.bcc];
      bcc.forEach((r) => formData.append("bcc", r.name ? `"${r.name}" <${r.email}>` : r.email));
    }

    formData.append("subject", message.subject);

    if (message.html) formData.append("html", message.html);
    if (message.text) formData.append("text", message.text);

    if (message.replyTo) formData.append("h:Reply-To", message.replyTo.email);

    if (message.headers) {
      Object.entries(message.headers).forEach(([k, v]) => {
        formData.append(`h:${k}`, v);
      });
    }

    if (message.tags) {
      message.tags.forEach((tag) => formData.append("o:tag", tag));
    }

    if (message.attachments) {
      message.attachments.forEach((att, i) => {
        formData.append(`attachment[${i}]`, new Blob([att.content], { type: att.contentType }), att.filename);
      });
    }

    return formData;
  }
}