export interface SendEmailOptions {
  from: string;
  to: string | string[];
  subject: string;
  html?: string;
  text?: string;
  replyTo?: string;
  tags?: string[];
  idempotencyKey?: string;
  scheduledAt?: string;
  attachmentIds?: string[];
}

export interface SendTemplateOptions {
  to: string;
  variables?: Record<string, string>;
}

export interface EmailMessage {
  id: string;
  organization_id: string;
  from_address: string;
  to_address: string;
  subject: string;
  status: string;
  environment: string;
  tags: string[];
  scheduled_at: string | null;
  sent_at: string | null;
  delivered_at: string | null;
  opened_at: string | null;
  clicked_at: string | null;
  failed_at: string | null;
  failure_reason: string | null;
  created_at: string;
}

export interface PaginatedResponse<T> {
  data: T[];
  meta: {
    page: number;
    perPage: number;
    total: number;
    pages: number;
    nextCursor?: string;
  };
}

export interface Domain {
  id: string;
  domain: string;
  status: string;
  dkim_verified: boolean;
  spf_verified: boolean;
  dmarc_verified: boolean;
  tracking_enabled: boolean;
  tracking_domain: string | null;
  created_at: string;
}

export interface DNSRecord {
  type: string;
  name: string;
  value: string;
  verified: boolean;
}

export interface Template {
  id: string;
  name: string;
  slug: string;
  description: string | null;
  current_version_id: string | null;
  created_at: string;
}

export interface TemplateVersion {
  id: string;
  version: number;
  subject: string;
  html_body: string;
  text_body: string | null;
  variables: Record<string, unknown>;
  is_published: boolean;
  created_at: string;
}

export interface Webhook {
  id: string;
  url: string;
  events: string[];
  status: string;
  created_at: string;
}

export interface WebhookDelivery {
  id: string;
  webhook_id: string;
  event_type: string;
  response_status: number | null;
  error_message: string | null;
  delivered_at: string | null;
  failed_at: string | null;
  created_at: string;
}

export interface Suppression {
  id: string;
  email: string;
  reason: string;
  created_at: string;
}

export interface Plan {
  id: string;
  name: string;
  slug: string;
  description: string | null;
  monthly_email_limit: number;
  price_cents: number;
  overage_rate_cents: number;
  sort_order: number;
  features: Record<string, unknown>;
}

export interface Subscription {
  id: string;
  planId: string;
  planName: string;
  planSlug: string;
  status: string;
  periodStart: string;
  periodEnd: string;
  cancelAtPeriodEnd: boolean;
  overageBalanceCents: number;
}

export interface UsageInfo {
  sentThisMonth: number;
  limit: number;
  monthStart: string;
  overageEnabled: boolean;
  planSlug: string;
  overageBalanceCents: number;
}

export interface Invoice {
  id: string;
  amount_cents: number;
  currency: string;
  status: string;
  description: string | null;
  created_at: string;
}

export interface AnalyticsOverview {
  total_sent: number;
  total_delivered: number;
  total_failed: number;
  total_opened: number;
  total_clicked: number;
  delivery_rate: number;
  open_rate: number;
  click_rate: number;
}

export interface CreateWebhookOptions {
  url: string;
  events: string[];
  secret?: string;
}

export interface APIKey {
  id: string;
  name: string;
  key_prefix: string;
  key_last_chars: string;
  scopes: string[];
  status: string;
  environment?: string;
  created_at: string;
}

export interface CreateAPIKeyOptions {
  name: string;
  scopes?: string[];
  expiresAt?: string;
  allowedIPs?: string[];
  environment?: "live" | "sandbox";
}

export interface Attachment {
  id: string;
  filename: string;
  contentType: string;
  size: number;
}
