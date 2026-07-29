/**
 * Database schema types generated from migrations
 * This file should be kept in sync with the actual database schema
 */

export interface Organization {
  id: string;
  name: string;
  slug: string;
  settings: Record<string, unknown>;
  ip_allowlist_enabled: boolean;
  ip_allowlist: string[];
  monthly_email_limit: number;
  emails_sent_this_month: number;
  month_start_date: Date;
  plan_id: string | null;
  overage_enabled: boolean;
  suspended_at: Date | null;
  status: string;
  created_at: Date;
  updated_at: Date;
  deleted_at: Date | null;
}

export interface Role {
  id: string;
  name: string;
  description: string | null;
  permissions: string[];
  created_at: Date;
  updated_at: Date;
}

export interface User {
  id: string;
  email: string;
  password_hash: string;
  first_name: string;
  last_name: string;
  timezone: string;
  locale: string;
  status: string;
  failed_login_attempts: number;
  locked_until: Date | null;
  last_login_at: Date | null;
  email_verified_at: Date | null;
  created_at: Date;
  updated_at: Date;
  deleted_at: Date | null;
}

export interface Membership {
  id: string;
  user_id: string;
  organization_id: string;
  role_id: string;
  status: string;
  joined_at: Date;
  created_at: Date;
  updated_at: Date;
}

export interface Team {
  id: string;
  organization_id: string;
  name: string;
  description: string | null;
  created_at: Date;
  updated_at: Date;
  deleted_at: Date | null;
}

export interface TeamMembership {
  id: string;
  team_id: string;
  user_id: string;
  role: string;
  created_at: Date;
}

export interface APIKey {
  id: string;
  organization_id: string;
  user_id: string | null;
  name: string;
  key_prefix: string;
  key_digest: string;
  key_last_chars: string;
  scopes: string[];
  allowed_ips: string[];
  status: string;
  expires_at: Date | null;
  last_used_at: Date | null;
  revoked_at: Date | null;
  created_at: Date;
  updated_at: Date;
  deleted_at: Date | null;
}

export interface Domain {
  id: string;
  organization_id: string;
  domain: string;
  dkim_selector: string;
  dkim_private_key_ciphertext: string | null;
  dkim_public_key: string | null;
  dkim_verified: boolean;
  dkim_verified_at: Date | null;
  spf_verified: boolean;
  spf_verified_at: Date | null;
  dmarc_verified: boolean;
  dmarc_verified_at: Date | null;
  tracking_enabled: boolean;
  tracking_domain: string | null;
  status: string;
  created_at: Date;
  updated_at: Date;
  deleted_at: Date | null;
}

export interface DNSRecord {
  id: string;
  domain_id: string;
  type: string;
  name: string;
  value: string;
  priority: number | null;
  ttl: number;
  verified: boolean;
  verified_at: Date | null;
  created_at: Date;
  updated_at: Date;
}

export interface Template {
  id: string;
  organization_id: string;
  name: string;
  slug: string;
  description: string | null;
  current_version_id: string | null;
  created_at: Date;
  updated_at: Date;
  deleted_at: Date | null;
}

export interface TemplateVersion {
  id: string;
  template_id: string;
  version: number;
  subject: string;
  html_body: string;
  text_body: string | null;
  variables: Record<string, unknown>;
  layout: string | null;
  is_published: boolean;
  published_at: Date | null;
  created_by: string | null;
  created_at: Date;
}

export interface EmailMessage {
  id: string;
  organization_id: string;
  batch_id: string;
  template_id: string | null;
  domain_id: string | null;
  from_address: string;
  to_address: string;
  recipient_type: string;
  subject: string;
  html_body: string | null;
  text_body: string | null;
  headers: Record<string, unknown>;
  tags: string[];
  status: string;
  idempotency_key: string | null;
  reply_to: string | null;
  message_id: string | null;
  retry_count: number;
  max_retries: number;
  environment: string;
  scheduled_at: Date | null;
  sent_at: Date | null;
  delivered_at: Date | null;
  failed_at: Date | null;
  last_retry_at: Date | null;
  failure_reason: string | null;
  failure_code: string | null;
  created_at: Date;
  updated_at: Date;
  deleted_at: Date | null;
}

export interface ProviderConfig {
  id: string;
  organization_id: string;
  provider_type: string;
  name: string;
  credentials_ciphertext: string;
  settings: Record<string, unknown>;
  weight: number;
  is_active: boolean;
  daily_limit: number | null;
  monthly_limit: number | null;
  created_at: Date;
  updated_at: Date;
  deleted_at: Date | null;
}

export interface Attachment {
  id: string;
  email_message_id: string | null;
  filename: string;
  content_type: string;
  size_bytes: number;
  storage_path: string;
  storage_provider: string;
  checksum: string;
  created_at: Date;
}

export interface Delivery {
  id: string;
  email_message_id: string;
  provider_config_id: string;
  provider_type: string;
  provider_message_id: string | null;
  status: string;
  scheduled_at: Date;
  sent_at: Date | null;
  delivered_at: Date | null;
  failed_at: Date | null;
  failure_reason: string | null;
  failure_code: string | null;
  retry_count: number;
  next_retry_at: Date | null;
  created_at: Date;
  updated_at: Date;
}

export interface ProviderAttempt {
  id: string;
  delivery_id: string;
  provider_type: string;
  provider_message_id: string | null;
  request_payload: Record<string, unknown> | null;
  response_payload: Record<string, unknown> | null;
  status_code: number | null;
  error_message: string | null;
  error_code: string | null;
  duration_ms: number;
  attempted_at: Date;
}

export interface DeliveryEvent {
  id: string;
  delivery_id: string;
  event_type: string;
  event_data: Record<string, unknown>;
  received_at: Date;
  processed_at: Date | null;
  processing_error: string | null;
}

export interface Webhook {
  id: string;
  organization_id: string;
  url: string;
  secret_ciphertext: string;
  events: string[];
  status: string;
  failure_count: number;
  last_success_at: Date | null;
  last_failure_at: Date | null;
  last_failure_reason: string | null;
  created_at: Date;
  updated_at: Date;
  deleted_at: Date | null;
}

export interface WebhookDelivery {
  id: string;
  webhook_id: string;
  event_type: string;
  payload: Record<string, unknown>;
  response_status: number | null;
  response_body: string | null;
  error_message: string | null;
  attempt: number;
  next_retry_at: Date | null;
  delivered_at: Date | null;
  failed_at: Date | null;
  created_at: Date;
}

export interface EmailMetrics {
  id: string;
  email_message_id: string;
  delivery_id: string | null;
  is_delivered: boolean;
  is_opened: boolean;
  is_clicked: boolean;
  is_bounced: boolean;
  is_complained: boolean;
  is_unsubscribed: boolean;
  opened_at: Date | null;
  clicked_at: Date | null;
  bounced_at: Date | null;
  complained_at: Date | null;
  unsubscribed_at: Date | null;
  open_count: number;
  click_count: number;
  user_agent: string | null;
  ip_address: string | null;
  country: string | null;
  device: string | null;
  browser: string | null;
  os: string | null;
  created_at: Date;
  updated_at: Date;
}

export interface Aggregate {
  id: string;
  organization_id: string;
  metric_name: string;
  granularity: string;
  bucket: Date;
  total_count: number;
  delivered_count: number;
  failed_count: number;
  bounced_count: number;
  opened_count: number;
  clicked_count: number;
  complained_count: number;
  queued_count: number;
  delivery_rate: number | null;
  open_rate: number | null;
  click_rate: number | null;
  bounce_rate: number | null;
  complaint_rate: number | null;
  avg_delivery_latency_ms: number | null;
  p50_latency_ms: number | null;
  p90_latency_ms: number | null;
  p99_latency_ms: number | null;
  created_at: Date;
  updated_at: Date;
}

export interface EventLog {
  id: string;
  event_type: string;
  entity_type: string;
  entity_id: string | null;
  organization_id: string | null;
  user_id: string | null;
  payload: Record<string, unknown>;
  metadata: Record<string, unknown>;
  created_at: Date;
}

export interface AuditLog {
  id: string;
  organization_id: string | null;
  user_id: string | null;
  action: string;
  resource_type: string;
  resource_id: string | null;
  old_values: Record<string, unknown> | null;
  new_values: Record<string, unknown> | null;
  ip_address: string | null;
  user_agent: string | null;
  created_at: Date;
}

export interface Job {
  id: string;
  job_type: string;
  payload: Record<string, unknown>;
  status: string;
  priority: number;
  scheduled_at: Date;
  started_at: Date | null;
  completed_at: Date | null;
  failed_at: Date | null;
  error_message: string | null;
  retry_count: number;
  max_retries: number;
  next_retry_at: Date | null;
  locked_by: string | null;
  locked_at: Date | null;
  created_at: Date;
  updated_at: Date;
}

export interface UsageRecord {
  id: string;
  organization_id: string;
  metric_name: string;
  period_start: Date;
  period_end: Date;
  count: number;
  metadata: Record<string, unknown>;
  created_at: Date;
}

export interface PartitionManagement {
  id: string;
  table_name: string;
  partition_name: string;
  partition_start: Date;
  partition_end: Date;
  row_count: number | null;
  size_bytes: number | null;
  is_attached: boolean;
  created_at: Date;
  attached_at: Date | null;
  detached_at: Date | null;
}

export interface MaterializedView {
  id: string;
  view_name: string;
  definition: string;
  is_populated: boolean;
  last_refreshed_at: Date | null;
  refresh_interval_seconds: number | null;
  created_at: Date;
  updated_at: Date;
}

export interface ProviderCost {
  id: string;
  organization_id: string;
  provider_type: string;
  date: Date;
  emails_sent: number;
  cost_cents: number;
  currency: string;
  created_at: Date;
  updated_at: Date;
}

export interface Suppression {
  id: string;
  organization_id: string;
  email: string;
  reason: string;
  source: string;
  created_at: Date;
}

export interface Plan {
  id: string;
  name: string;
  slug: string;
  description: string | null;
  monthly_email_limit: number;
  price_cents: number;
  overage_rate_cents: number;
  features: Record<string, unknown>;
  is_active: boolean;
  sort_order: number;
  created_at: Date;
  updated_at: Date;
}

export interface Subscription {
  id: string;
  organization_id: string;
  plan_id: string;
  status: string;
  period_start: Date;
  period_end: Date;
  cancel_at_period_end: boolean;
  stripe_subscription_id: string | null;
  paystack_subscription_code: string | null;
  paystack_authorization_code: string | null;
  overage_balance_cents: number;
  created_at: Date;
  updated_at: Date;
}

export interface Invoice {
  id: string;
  organization_id: string;
  subscription_id: string | null;
  amount_cents: number;
  currency: string;
  status: string;
  description: string | null;
  period_start: Date | null;
  period_end: Date | null;
  paid_at: Date | null;
  paystack_reference: string | null;
  created_at: Date;
  updated_at: Date;
}

export interface RetentionPolicy {
  id: string;
  organization_id: string | null;
  table_name: string;
  retention_days: number;
  enabled: boolean;
  created_at: Date;
  updated_at: Date;
}

export interface Rollup1m {
  id: string;
  organization_id: string;
  metric: string;
  bucket: Date;
  count: number;
  error_count: number;
  latency_avg: number | null;
  latency_p50: number | null;
  latency_p90: number | null;
  latency_p99: number | null;
  created_at: Date;
  updated_at: Date;
}

export interface Rollup5m {
  id: string;
  organization_id: string;
  metric: string;
  bucket: Date;
  count: number;
  error_count: number;
  latency_avg: number | null;
  latency_p50: number | null;
  latency_p90: number | null;
  latency_p99: number | null;
  created_at: Date;
  updated_at: Date;
}

export interface RollupDailyDomain {
  id: string;
  organization_id: string;
  domain_id: string | null;
  date: Date;
  total_sent: number;
  delivered: number;
  bounced: number;
  complained: number;
  opened: number;
  clicked: number;
  created_at: Date;
  updated_at: Date;
}

export interface DB {
  organizations: Organization;
  roles: Role;
  users: User;
  memberships: Membership;
  teams: Team;
  team_memberships: TeamMembership;
  api_keys: APIKey;
  domains: Domain;
  dns_records: DNSRecord;
  templates: Template;
  template_versions: TemplateVersion;
  email_messages: EmailMessage;
  provider_configs: ProviderConfig;
  attachments: Attachment;
  deliveries: Delivery;
  provider_attempts: ProviderAttempt;
  delivery_events: DeliveryEvent;
  webhooks: Webhook;
  webhook_deliveries: WebhookDelivery;
  email_metrics: EmailMetrics;
  aggregates: Aggregate;
  event_logs: EventLog;
  audit_logs: AuditLog;
  jobs: Job;
  usage_records: UsageRecord;
  partition_management: PartitionManagement;
  materialized_views: MaterializedView;
  provider_costs: ProviderCost;
  retention_policies: RetentionPolicy;
  rollup_1m: Rollup1m;
  rollup_5m: Rollup5m;
  rollup_daily_domain: RollupDailyDomain;
  suppressions: Suppression;
  plans: Plan;
  subscriptions: Subscription;
  invoices: Invoice;
}