import type { SendEmailMessage, ProviderAdapterConfig, ProviderResponse } from "@resendbyte/types";
import { BaseProviderAdapter } from "./ProviderAdapter.js";

export class SESAdapter extends BaseProviderAdapter {
  readonly type = "ses" as const;
  readonly name = "Amazon SES";

  async send(message: SendEmailMessage, config: ProviderAdapterConfig): Promise<ProviderResponse> {
    this.validateEmail(message);

    const { accessKey, secretKey, region } = config;
    if (!accessKey || !secretKey || !region) {
      return { success: false, error: "AWS credentials and region are required" };
    }

    try {
      const { SESClient, SendRawEmailCommand } = await import("@aws-sdk/client-ses");

      const client = new SESClient({
        region,
        credentials: {
          accessKeyId: accessKey,
          secretAccessKey: secretKey,
        },
      });

      const rawEmail = this.buildRawEmail(message);

      const command = new SendRawEmailCommand({
        RawMessage: { Data: Buffer.from(rawEmail) },
        ConfigurationSetName: config.configurationSet,
      });

      const result = await client.send(command);

      return {
        success: true,
        messageId: result.MessageId || this.generateMessageId(),
        providerResponse: { messageId: result.MessageId },
      };
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : "Unknown error",
      };
    }
  }

  async validateConfig(config: ProviderAdapterConfig): Promise<boolean> {
    return !!(config.accessKey && config.secretKey && config.region);
  }

  async healthCheck(config: ProviderAdapterConfig): Promise<{ healthy: boolean; latency: number }> {
    const start = Date.now();
    try {
      const { SESClient, GetAccountSendingEnabledCommand } = await import("@aws-sdk/client-ses");
      const client = new SESClient({
        region: config.region!,
        credentials: {
          accessKeyId: config.accessKey!,
          secretAccessKey: config.secretKey!,
        },
      });
      const response = await client.send(new GetAccountSendingEnabledCommand({}));
      return { healthy: response.Enabled === true, latency: Date.now() - start };
    } catch {
      return { healthy: false, latency: Date.now() - start };
    }
  }

  protected buildRequest(message: SendEmailMessage, config: ProviderAdapterConfig): any {
    return this.buildRawEmail(message);
  }

  protected parseResponse(response: any): ProviderResponse {
    return {
      success: true,
      messageId: response.MessageId || this.generateMessageId(),
      providerResponse: { messageId: response.MessageId },
    };
  }

  private buildRawEmail(message: SendEmailMessage): string {
    const lines: string[] = [];

    const from = message.from.name
      ? `"${message.from.name}" <${message.from.email}>`
      : message.from.email;
    lines.push(`From: ${from}`);

    const to = Array.isArray(message.to) ? message.to : [message.to];
    lines.push(`To: ${to.map(r => r.name ? `"${r.name}" <${r.email}>` : r.email).join(", ")}`);

    if (message.cc) {
      const cc = Array.isArray(message.cc) ? message.cc : [message.cc];
      lines.push(`Cc: ${cc.map(r => r.name ? `"${r.name}" <${r.email}>` : r.email).join(", ")}`);
    }

    if (message.bcc) {
      const bcc = Array.isArray(message.bcc) ? message.bcc : [message.bcc];
      lines.push(`Bcc: ${bcc.map(r => r.name ? `"${r.name}" <${r.email}>` : r.email).join(", ")}`);
    }

    if (message.replyTo) {
      lines.push(`Reply-To: ${message.replyTo.email}`);
    }

    lines.push(`Subject: ${message.subject}`);
    lines.push("MIME-Version: 1.0");

    if (message.html && message.text) {
      lines.push("Content-Type: multipart/alternative; boundary=\"boundary123\"");
      lines.push("");
      lines.push("--boundary123");
      lines.push("Content-Type: text/plain; charset=UTF-8");
      lines.push("");
      lines.push(message.text);
      lines.push("");
      lines.push("--boundary123");
      lines.push("Content-Type: text/html; charset=UTF-8");
      lines.push("");
      lines.push(message.html);
      lines.push("");
      lines.push("--boundary123--");
    } else if (message.html) {
      lines.push("Content-Type: text/html; charset=UTF-8");
      lines.push("");
      lines.push(message.html);
    } else {
      lines.push("Content-Type: text/plain; charset=UTF-8");
      lines.push("");
      lines.push(message.text || "");
    }

    return lines.join("\r\n");
  }
}