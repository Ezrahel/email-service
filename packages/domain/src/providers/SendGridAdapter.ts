import type { SendEmailMessage, ProviderAdapterConfig, ProviderResponse } from "@resendbyte/types";
import { BaseProviderAdapter } from "./ProviderAdapter.js";

export class SendGridAdapter extends BaseProviderAdapter {
  readonly type = "sendgrid" as const;
  readonly name = "SendGrid";

  async send(message: SendEmailMessage, config: ProviderAdapterConfig): Promise<ProviderResponse> {
    this.validateEmail(message);

    const apiKey = config.apiKey;
    if (!apiKey) {
      return { success: false, error: "SendGrid API key is required" };
    }

    const mail = this.buildSendGridMail(message);

    try {
      const response = await fetch("https://api.sendgrid.com/v3/mail/send", {
        method: "POST",
        headers: {
          "Authorization": `Bearer ${apiKey}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify(mail),
      });

      if (!response.ok) {
        const error: any = await response.json();
        return {
          success: false,
          error: error.errors?.[0]?.message || "SendGrid API error",
          errorCode: response.status.toString(),
          providerResponse: error,
        };
      }

      const messageId = response.headers.get("X-Message-Id") || this.generateMessageId();

      return {
        success: true,
        messageId,
        providerResponse: { statusCode: response.status },
      };
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : "Unknown error",
      };
    }
  }

  async validateConfig(config: ProviderAdapterConfig): Promise<boolean> {
    return !!config.apiKey && config.apiKey.startsWith("SG.");
  }

  async healthCheck(config: ProviderAdapterConfig): Promise<{ healthy: boolean; latency: number }> {
    const start = Date.now();
    try {
      const response = await fetch("https://api.sendgrid.com/v3/user/profile", {
        headers: { Authorization: `Bearer ${config.apiKey}` },
      });
      return { healthy: response.ok, latency: Date.now() - start };
    } catch {
      return { healthy: false, latency: Date.now() - start };
    }
  }

  protected buildRequest(message: SendEmailMessage, config: ProviderAdapterConfig): any {
    return this.buildSendGridMail(message);
  }

  protected parseResponse(response: any): ProviderResponse {
    return {
      success: true,
      messageId: response.messageId || this.generateMessageId(),
      providerResponse: response,
    };
  }

  private buildSendGridMail(message: SendEmailMessage): any {
    const to = Array.isArray(message.to) ? message.to : [message.to];
    const personalizations = to.map((recipient) => ({
      to: [{ email: recipient.email, name: recipient.name }],
      subject: message.subject,
      ...(message.replyTo && { reply_to: { email: message.replyTo.email, name: message.replyTo.name } }),
      headers: message.headers,
    }));

    return {
      personalizations,
      from: {
        email: message.from.email,
        name: message.from.name,
      },
      reply_to: message.replyTo ? { email: message.replyTo.email, name: message.replyTo.name } : undefined,
      subject: message.subject,
      content: [
        ...(message.text ? [{ type: "text/plain", value: message.text }] : []),
        ...(message.html ? [{ type: "text/html", value: message.html }] : []),
      ],
      ...(message.attachments && {
        attachments: message.attachments.map((att) => ({
          content: Buffer.isBuffer(att.content) ? att.content.toString("base64") : Buffer.from(att.content).toString("base64"),
          filename: att.filename,
          type: att.contentType,
          disposition: att.disposition || "attachment",
          content_id: att.contentId,
        })),
      }),
      headers: message.headers,
      tracking_settings: {
        click_tracking: { enable: true },
        open_tracking: { enable: true },
      },
    };
  }
}