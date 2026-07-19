/**
 * Branded types for type-safe IDs
 * Uses nominal typing pattern with unique symbol
 */

declare const __brand: unique symbol;

export type Brand<T, B extends string> = T & { readonly [__brand]: B };

export type UserID = Brand<string, "UserID">;
export type RoleID = Brand<string, "RoleID">;
export type TeamID = Brand<string, "TeamID">;
export type OrganizationID = Brand<string, "OrganizationID">;
export type MembershipID = Brand<string, "MembershipID">;
export type TeamMembershipID = Brand<string, "TeamMembershipID">;
export type DomainID = Brand<string, "DomainID">;
export type DNSRecordID = Brand<string, "DNSRecordID">;
export type TemplateID = Brand<string, "TemplateID">;
export type TemplateVersionID = Brand<string, "TemplateVersionID">;
export type EmailMessageID = Brand<string, "EmailMessageID">;
export type BatchID = Brand<string, "BatchID">;
export type ProviderConfigID = Brand<string, "ProviderConfigID">;
export type DeliveryID = Brand<string, "DeliveryID">;
export type ProviderAttemptID = Brand<string, "ProviderAttemptID">;
export type DeliveryEventID = Brand<string, "DeliveryEventID">;
export type WebhookID = Brand<string, "WebhookID">;
export type WebhookDeliveryID = Brand<string, "WebhookDeliveryID">;
export type APIKeyID = Brand<string, "APIKeyID">;
export type APIKeyPrefix = Brand<string, "APIKeyPrefix">;
export type EmailMetricsID = Brand<string, "EmailMetricsID">;
export type AggregateID = Brand<string, "AggregateID">;
export type EventLogID = Brand<string, "EventLogID">;
export type AuditLogID = Brand<string, "AuditLogID">;
export type JobID = Brand<string, "JobID">;
export type UsageRecordID = Brand<string, "UsageRecordID">;
export type PartitionManagementID = Brand<string, "PartitionManagementID">;
export type MaterializedViewID = Brand<string, "MaterializedViewID">;
export type RetentionPolicyID = Brand<string, "RetentionPolicyID">;
export type RollupTableID = Brand<string, "RollupTableID">;
export type PartitionID = Brand<string, "PartitionID">;
export type ProviderCostID = Brand<string, "ProviderCostID">;

/**
 * Type guards for branded types
 */
export function isUserID(value: unknown): value is UserID {
  return typeof value === "string" && value.length > 0;
}

export function isOrganizationID(value: unknown): value is OrganizationID {
  return typeof value === "string" && value.length > 0;
}

export function isDomainID(value: unknown): value is DomainID {
  return typeof value === "string" && value.length > 0;
}

export function isTemplateID(value: unknown): value is TemplateID {
  return typeof value === "string" && value.length > 0;
}

export function isEmailMessageID(value: unknown): value is EmailMessageID {
  return typeof value === "string" && value.length > 0;
}

export function isAPIKeyID(value: unknown): value is APIKeyID {
  return typeof value === "string" && value.length > 0;
}

/**
 * Create branded types from strings (use with caution, validate first)
 */
export function createUserID(id: string): UserID {
  return id as UserID;
}

export function createOrganizationID(id: string): OrganizationID {
  return id as OrganizationID;
}

export function createDomainID(id: string): DomainID {
  return id as DomainID;
}

export function createTemplateID(id: string): TemplateID {
  return id as TemplateID;
}

export function createEmailMessageID(id: string): EmailMessageID {
  return id as EmailMessageID;
}

export function createAPIKeyID(id: string): APIKeyID {
  return id as APIKeyID;
}

/**
 * Generate new branded IDs
 */
import { randomUUID } from "crypto";

export function generateUserID(): UserID {
  return randomUUID() as UserID;
}

export function generateOrganizationID(): OrganizationID {
  return randomUUID() as OrganizationID;
}

export function generateDomainID(): DomainID {
  return randomUUID() as DomainID;
}

export function generateTemplateID(): TemplateID {
  return randomUUID() as TemplateID;
}

export function generateEmailMessageID(): EmailMessageID {
  return randomUUID() as EmailMessageID;
}

export function generateAPIKeyID(): APIKeyID {
  return randomUUID() as APIKeyID;
}

/**
 * Entity status enums
 */
export enum EntityStatus {
  ACTIVE = "active",
  INACTIVE = "inactive",
  PENDING = "pending",
  DELETED = "deleted",
  SUSPENDED = "suspended",
}

export enum EmailStatus {
  QUEUED = "queued",
  SENDING = "sending",
  SENT = "sent",
  DELIVERED = "delivered",
  OPENED = "opened",
  CLICKED = "clicked",
  BOUNCED = "bounced",
  COMPLAINED = "complained",
  FAILED = "failed",
  CANCELLED = "cancelled",
}

export enum DeliveryStatus {
  PENDING = "pending",
  QUEUED = "queued",
  SENDING = "sending",
  SENT = "sent",
  DELIVERED = "delivered",
  BOUNCED = "bounced",
  FAILED = "failed",
  DEFERRED = "deferred",
}

export enum ProviderType {
  SMTP = "smtp",
  MAILGUN = "mailgun",
  SENDGRID = "sendgrid",
  SES = "ses",
  POSTMARK = "postmark",
}

export enum WebhookEventType {
  EMAIL_SENT = "email.sent",
  EMAIL_DELIVERED = "email.delivered",
  EMAIL_OPENED = "email.opened",
  EMAIL_CLICKED = "email.clicked",
  EMAIL_BOUNCED = "email.bounced",
  EMAIL_COMPLAINED = "email.complained",
  EMAIL_FAILED = "email.failed",
}

export enum JobStatus {
  PENDING = "pending",
  RUNNING = "running",
  COMPLETED = "completed",
  FAILED = "failed",
  RETRYING = "retrying",
  CANCELLED = "cancelled",
}

export enum JobType {
  EMAIL_SUBMISSION = "email_submission",
  EMAIL_BATCH = "email_batch",
  EMAIL_RETRY = "email_retry",
  DELIVERY_PROCESS = "delivery_process",
  DELIVERY_RETRY = "delivery_retry",
  WEBHOOK_DELIVERY = "webhook_delivery",
  WEBHOOK_RETRY = "webhook_retry",
  ANALYTICS_ROLLUP = "analytics_rollup",
  PARTITION_MAINTENANCE = "partition_maintenance",
  CLEANUP = "cleanup",
}

/**
 * Pagination types
 */
export interface PaginationParams {
  page?: number;
  perPage?: number;
  sortBy?: string;
  sortOrder?: "asc" | "desc";
}

export interface PaginatedResponse<T> {
  data: T[];
  meta: {
    page: number;
    perPage: number;
    total: number;
    totalPages: number;
  };
}

export function createPaginationMeta(
  page: number,
  perPage: number,
  total: number
): PaginatedResponse<any>["meta"] {
  return {
    page,
    perPage,
    total,
    totalPages: Math.ceil(total / perPage),
  };
}

/**
 * Common filter types
 */
export interface DateRangeFilter {
  from?: Date;
  to?: Date;
}

export interface IDFilter<T extends string = string> {
  ids?: T[];
  id?: T;
}

export interface StatusFilter<T extends string = string> {
  status?: T[];
}

/**
 * Sort types
 */
export interface SortOptions {
  field: string;
  order: "asc" | "desc";
}

export function parseSort(sort?: string): SortOptions | null {
  if (!sort) return null;
  const parts = sort.split(":");
  const field = parts[0];
  const order = parts[1];
  if (!field) return null;
  return {
    field,
    order: (order?.toLowerCase() === "desc" ? "desc" : "asc") as "asc" | "desc",
  };
}