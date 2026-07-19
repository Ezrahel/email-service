export * from "./branded.js";

/**
 * Better Auth types
 */
export interface BetterAuthUser {
  id: string;
  email: string;
  emailVerified: boolean;
  name?: string;
  image?: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface BetterAuthSession {
  id: string;
  userId: string;
  expiresAt: Date;
  token: string;
  ipAddress?: string;
  userAgent?: string;
}

export interface BetterAuthAccount {
  id: string;
  userId: string;
  providerId: string;
  accountId: string;
  accessToken?: string;
  refreshToken?: string;
  expiresAt?: Date;
  password?: string;
}

/**
 * API Key types
 */
export interface APIKey {
  id: string;
  organizationId: string;
  userId: string | null;
  name: string;
  keyPrefix: string;
  keyDigest: string;
  keyLastChars: string;
  scopes: string[];
  allowedIPs: string[];
  status: "active" | "revoked" | "expired";
  expiresAt: Date | null;
  lastUsedAt: Date | null;
  createdAt: Date;
  updatedAt: Date;
}

/**
 * Email types
 */
export interface EmailMessage {
  id: string;
  organizationId: string;
  batchId: string;
  templateId: string | null;
  domainId: string | null;
  fromAddress: string;
  toAddress: string;
  recipientType: string;
  subject: string;
  htmlBody: string | null;
  textBody: string | null;
  headers: Record<string, unknown>;
  tags: string[];
  status: string;
  idempotencyKey: string | null;
  replyTo: string | null;
  messageId: string | null;
  retryCount: number;
  maxRetries: number;
  scheduledAt: Date | null;
  sentAt: Date | null;
  deliveredAt: Date | null;
  failedAt: Date | null;
  lastRetryAt: Date | null;
  failureReason: string | null;
  failureCode: string | null;
  createdAt: Date;
  updatedAt: Date;
  deletedAt: Date | null;
}

/**
 * Template types
 */
export interface Template {
  id: string;
  organizationId: string;
  name: string;
  slug: string;
  description: string | null;
  currentVersionId: string | null;
  createdAt: Date;
  updatedAt: Date;
  deletedAt: Date | null;
}

export interface TemplateVersion {
  id: string;
  templateId: string;
  version: number;
  subject: string;
  htmlBody: string;
  textBody: string | null;
  variables: Record<string, unknown>;
  layout: string | null;
  isPublished: boolean;
  publishedAt: Date | null;
  createdBy: string | null;
  createdAt: Date;
}

/**
 * Domain types
 */
export interface Domain {
  id: string;
  organizationId: string;
  domain: string;
  dkimSelector: string;
  dkimPrivateKeyCiphertext: string | null;
  dkimPublicKey: string | null;
  dkimVerified: boolean;
  dkimVerifiedAt: Date | null;
  spfVerified: boolean;
  spfVerifiedAt: Date | null;
  dmarcVerified: boolean;
  dmarcVerifiedAt: Date | null;
  trackingEnabled: boolean;
  trackingDomain: string | null;
  status: string;
  createdAt: Date;
  updatedAt: Date;
  deletedAt: Date | null;
}

/**
 * Provider config types
 */
export interface ProviderConfig {
  id: string;
  organizationId: string;
  providerType: string;
  name: string;
  credentialsCiphertext: string;
  settings: Record<string, unknown>;
  weight: number;
  isActive: boolean;
  dailyLimit: number | null;
  monthlyLimit: number | null;
  createdAt: Date;
  updatedAt: Date;
  deletedAt: Date | null;
}

/**
 * Webhook types
 */
export interface Webhook {
  id: string;
  organizationId: string;
  url: string;
  secretCiphertext: string;
  events: string[];
  status: string;
  failureCount: number;
  lastSuccessAt: Date | null;
  lastFailureAt: Date | null;
  lastFailureReason: string | null;
  createdAt: Date;
  updatedAt: Date;
  deletedAt: Date | null;
}

/**
 * Analytics types
 */
export interface AnalyticsOverview {
  period: string;
  sent: number;
  delivered: number;
  bounced: number;
  complained: number;
  opened: number;
  clicked: number;
  deliveryRate: number;
  bounceRate: number;
  openRate: number;
  clickRate: number;
}

export interface ProviderStats {
  providerType: string;
  count: number;
  delivered: number;
  bounced: number;
}

export interface ActivityPoint {
  created_at: Date;
  count: number;
}

/**
 * Email sending types (used by provider adapters)
 */
export interface EmailRecipient {
  email: string;
  name?: string;
}

export interface EmailAttachment {
  filename: string;
  content: string | Buffer;
  contentType: string;
  contentId?: string;
  disposition?: "attachment" | "inline";
}

export interface SendEmailMessage {
  id?: string;
  from: EmailRecipient;
  to: EmailRecipient | EmailRecipient[];
  cc?: EmailRecipient | EmailRecipient[];
  bcc?: EmailRecipient | EmailRecipient[];
  replyTo?: EmailRecipient;
  subject: string;
  html?: string;
  text?: string;
  headers?: Record<string, string>;
  attachments?: EmailAttachment[];
  tags?: string[];
  metadata?: Record<string, string>;
  scheduledAt?: Date;
  messageId?: string;
}

/**
 * Provider types
 */
export type ProviderType = "smtp" | "sendgrid" | "mailgun" | "ses" | "postmark";

export interface ProviderResponse {
  success: boolean;
  messageId?: string;
  error?: string;
  errorCode?: string;
  statusCode?: number;
  providerResponse?: unknown;
}

export interface ProviderHealth {
  healthy: boolean;
  latency: number;
  lastCheck: number;
  lastSuccess?: number;
  lastError?: number;
  lastErrorMessage?: string;
  failures?: number;
  cooldownUntil?: number;
  enabled?: boolean;
  priority?: number;
  weight?: number;
}

export interface SmtpAuth {
  user: string;
  pass: string;
}

export interface ProviderAdapterConfig {
  apiKey?: string;
  host?: string;
  port?: number;
  secure?: boolean;
  auth?: SmtpAuth;
  tls?: Record<string, unknown>;
  pool?: boolean;
  maxConnections?: number;
  maxMessages?: number;
  connectionTimeout?: number;
  domain?: string;
  region?: string;
  accessKey?: string;
  secretKey?: string;
  configurationSet?: string;
  settings?: Record<string, unknown>;
}