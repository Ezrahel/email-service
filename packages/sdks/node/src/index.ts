import { HttpClient } from "./client.js";
import { EmailsResource } from "./emails.js";
import { DomainsResource } from "./domains.js";
import { TemplatesResource } from "./templates.js";
import { WebhooksResource } from "./webhooks.js";
import { SuppressionsResource } from "./suppressions.js";
import { BillingResource } from "./billing.js";
import { AnalyticsResource } from "./analytics.js";
import type {
  SendEmailOptions,
  SendTemplateOptions,
  EmailMessage,
  PaginatedResponse,
  Domain,
  Template,
  Webhook,
  WebhookDelivery,
  Suppression,
  Plan,
  Subscription,
  UsageInfo,
  Invoice,
  AnalyticsOverview,
  CreateWebhookOptions,
  APIKey,
  CreateAPIKeyOptions,
  Attachment,
} from "./types.js";

export type {
  SendEmailOptions,
  SendTemplateOptions,
  EmailMessage,
  PaginatedResponse,
  Domain,
  Template,
  Webhook,
  WebhookDelivery,
  Suppression,
  Plan,
  Subscription,
  UsageInfo,
  Invoice,
  AnalyticsOverview,
  CreateWebhookOptions,
  APIKey,
  CreateAPIKeyOptions,
  Attachment,
};

export { HttpClient } from "./client.js";
export { EmailsResource } from "./emails.js";
export { DomainsResource } from "./domains.js";
export { TemplatesResource } from "./templates.js";
export { WebhooksResource } from "./webhooks.js";
export { SuppressionsResource } from "./suppressions.js";
export { BillingResource } from "./billing.js";
export { AnalyticsResource } from "./analytics.js";

export class EmailService {
  public http: HttpClient;
  public emails: EmailsResource;
  public domains: DomainsResource;
  public templates: TemplatesResource;
  public webhooks: WebhooksResource;
  public suppressions: SuppressionsResource;
  public billing: BillingResource;
  public analytics: AnalyticsResource;

  constructor(options: { apiKey: string; baseUrl?: string }) {
    this.http = new HttpClient(options);
    this.emails = new EmailsResource(this.http);
    this.domains = new DomainsResource(this.http);
    this.templates = new TemplatesResource(this.http);
    this.webhooks = new WebhooksResource(this.http);
    this.suppressions = new SuppressionsResource(this.http);
    this.billing = new BillingResource(this.http);
    this.analytics = new AnalyticsResource(this.http);
  }
}

export default EmailService;
