import type { SendEmailMessage, ProviderAdapterConfig, ProviderResponse } from "@email-service/types";
import { BaseProviderAdapter } from "./ProviderAdapter.js";

export class SmtpAdapter extends BaseProviderAdapter {
  readonly type = "smtp" as const;
  readonly name = "SMTP";

  async send(message: SendEmailMessage, config: ProviderAdapterConfig): Promise<ProviderResponse> {
    this.validateEmail(message);

    const nodemailer = await import("nodemailer");

    const transporter = nodemailer.createTransport({
      host: config.host,
      port: config.port || 587,
      secure: config.secure || false,
      auth: config.auth ? {
        user: config.auth.user,
        pass: config.auth.pass,
      } : undefined,
      tls: config.tls,
      pool: config.pool || false,
      maxConnections: config.maxConnections || 5,
      maxMessages: config.maxMessages || 100,
    } as any);

    const mailOptions = this.buildMailOptions(message);

    try {
      const info = await transporter.sendMail(mailOptions);
      return {
        success: true,
        messageId: info.messageId || this.generateMessageId(),
        providerResponse: info,
      };
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : "Unknown error",
        errorCode: (error as any).code,
      };
    } finally {
      await transporter.close();
    }
  }

  async validateConfig(config: ProviderAdapterConfig): Promise<boolean> {
    if (!config.host) return false;
    if (!config.port) return false;
    if (config.auth && (!config.auth.user || !config.auth.pass)) return false;
    return true;
  }

  async healthCheck(config: ProviderAdapterConfig): Promise<{ healthy: boolean; latency: number }> {
    const start = Date.now();
    try {
      const nodemailer = await import("nodemailer");
      const transporter = nodemailer.createTransport({
        host: config.host,
        port: config.port || 587,
        secure: config.secure || false,
        auth: config.auth ? { user: config.auth.user, pass: config.auth.pass } : undefined,
        connectionTimeout: 5000,
      });

      await transporter.verify();
      await transporter.close();
      return { healthy: true, latency: Date.now() - start };
    } catch {
      return { healthy: false, latency: Date.now() - start };
    }
  }

  protected buildMailOptions(message: SendEmailMessage): any {
    return {
      from: message.from.name
        ? `"${message.from.name}" <${message.from.email}>`
        : message.from.email,
      to: Array.isArray(message.to)
        ? message.to.map(e => e.email).join(", ")
        : (message.to as any).email,
      subject: message.subject,
      text: message.text,
      html: message.html,
      replyTo: message.replyTo?.email,
      headers: message.headers,
      messageId: message.messageId || this.generateMessageId(),
      ...(message.attachments && { attachments: message.attachments }),
    };
  }

  protected buildRequest(message: SendEmailMessage, config: ProviderAdapterConfig): any {
    return this.buildMailOptions(message);
  }

  protected parseResponse(response: any): ProviderResponse {
    return {
      success: true,
      messageId: response.messageId || this.generateMessageId(),
      providerResponse: response,
    };
  }
}