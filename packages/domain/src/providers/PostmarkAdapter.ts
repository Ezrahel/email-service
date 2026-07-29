import type { SendEmailMessage, ProviderAdapterConfig, ProviderResponse } from "@resendbyte/types";
import { BaseProviderAdapter } from "./ProviderAdapter.js";

export class PostmarkAdapter extends BaseProviderAdapter {
  readonly type = "postmark" as const;
  readonly name = "Postmark";

  async send(message: SendEmailMessage, config: ProviderAdapterConfig): Promise<ProviderResponse> {
    this.validateEmail(message);

    const apiKey = config.apiKey;
    if (!apiKey) {
      return { success: false, error: "Postmark API key is required" };
    }

    const mail = this.buildPostmarkMail(message);

    try {
      const response = await fetch("https://api.postmarkapp.com/email", {
        method: "POST",
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "X-Postmark-Server-Token": apiKey,
        },
        body: JSON.stringify(mail),
      });

      if (!response.ok) {
        const error: any = await response.json();
        return {
          success: false,
          error: error.Message || "Postmark API error",
          errorCode: response.status.toString(),
          providerResponse: error,
        };
      }

      const result: any = await response.json();
      return {
        success: true,
        messageId: result.MessageID || this.generateMessageId(),
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
    return !!config.apiKey;
  }

  async healthCheck(config: ProviderAdapterConfig): Promise<{ healthy: boolean; latency: number }> {
    const start = Date.now();
    try {
      const response = await fetch("https://api.postmarkapp.com/user", {
        headers: {
          "Accept": "application/json",
          "X-Postmark-Server-Token": config.apiKey!,
        },
      });
      return { healthy: response.ok, latency: Date.now() - start };
    } catch {
      return { healthy: false, latency: Date.now() - start };
    }
  }

  protected buildRequest(message: SendEmailMessage, config: ProviderAdapterConfig): any {
    return this.buildPostmarkMail(message);
  }

  protected parseResponse(response: any): ProviderResponse {
    return {
      success: true,
      messageId: response.MessageID || this.generateMessageId(),
      providerResponse: response,
    };
  }

  private buildPostmarkMail(message: SendEmailMessage): any {
    const to = Array.isArray(message.to)
      ? message.to.map(r => r.name ? `"${r.name}" <${r.email}>` : r.email).join(", ")
      : (message.to as any).email;

    return {
      From: message.from.name ? `"${message.from.name}" <${message.from.email}>` : message.from.email,
      To: to,
      Subject: message.subject,
      HtmlBody: message.html,
      TextBody: message.text,
      ReplyTo: message.replyTo?.email,
      ...(message.headers && { Headers: Object.entries(message.headers).map(([k, v]) => ({ Name: k, Value: v })) }),
      ...(message.attachments && {
        Attachments: message.attachments.map(att => ({
          Name: att.filename,
          Content: Buffer.isBuffer(att.content) ? att.content.toString("base64") : Buffer.from(att.content).toString("base64"),
          ContentType: att.contentType,
          ContentID: att.contentId,
        })),
      }),
      ...(message.tags && { Tag: message.tags[0] }),
      TrackOpens: true,
      TrackLinks: "HtmlAndText",
    };
  }
}