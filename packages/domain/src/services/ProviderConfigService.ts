import { db } from "@resendbyte/database";
import { ValidationError, NotFoundError } from "@resendbyte/errors";
import { encryptSecret } from "@resendbyte/crypto";
import crypto from "node:crypto";
import type { ProviderType } from "@resendbyte/types";

const SUPPORTED_PROVIDERS: ProviderType[] = ["smtp", "sendgrid", "mailgun", "ses", "postmark"];

export interface CreateProviderConfigInput {
  providerType: ProviderType;
  name: string;
  credentials: string;
  settings?: Record<string, unknown>;
  weight?: number;
  isActive?: boolean;
  dailyLimit?: number | null;
  monthlyLimit?: number | null;
}

export interface UpdateProviderConfigInput {
  name?: string;
  credentials?: string;
  settings?: Record<string, unknown>;
  weight?: number;
  isActive?: boolean;
  dailyLimit?: number | null;
  monthlyLimit?: number | null;
}

export interface ProviderConfigResult {
  id: string;
  providerType: string;
  name: string;
  settings: Record<string, unknown>;
  weight: number;
  isActive: boolean;
  hasCredentials: boolean;
  dailyLimit: number | null;
  monthlyLimit: number | null;
  createdAt: Date;
  updatedAt: Date;
}

const QUERY_COLUMNS = [
  "id",
  "organization_id",
  "provider_type",
  "name",
  "credentials_ciphertext",
  "settings",
  "weight",
  "is_active",
  "daily_limit",
  "monthly_limit",
  "created_at",
  "updated_at",
] as const;

function mapToResult(row: any): ProviderConfigResult {
  return {
    id: row.id,
    providerType: row.provider_type,
    name: row.name,
    settings: row.settings ?? {},
    weight: row.weight,
    isActive: row.is_active,
    hasCredentials: Boolean(row.credentials_ciphertext),
    dailyLimit: row.daily_limit ?? null,
    monthlyLimit: row.monthly_limit ?? null,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

function assertProviderType(providerType: string): asserts providerType is ProviderType {
  if (!SUPPORTED_PROVIDERS.includes(providerType as ProviderType)) {
    throw new ValidationError(`Unsupported provider type: ${providerType}`);
  }
}

export class ProviderConfigService {
  async list(organizationId: string): Promise<ProviderConfigResult[]> {
    const rows = await db
      .selectFrom("provider_configs")
      .select(QUERY_COLUMNS)
      .where("organization_id", "=", organizationId)
      .where("deleted_at", "is", null)
      .orderBy("created_at", "desc")
      .execute();
    return rows.map(mapToResult);
  }

  async get(organizationId: string, id: string): Promise<ProviderConfigResult> {
    const row = await db
      .selectFrom("provider_configs")
      .select(QUERY_COLUMNS)
      .where("id", "=", id)
      .where("organization_id", "=", organizationId)
      .where("deleted_at", "is", null)
      .executeTakeFirst();
    if (!row) throw new NotFoundError("Provider config not found");
    return mapToResult(row);
  }

  async create(organizationId: string, input: CreateProviderConfigInput): Promise<ProviderConfigResult> {
    if (!input.name?.trim()) throw new ValidationError("Name is required");
    if (!input.credentials) throw new ValidationError("Credentials are required");
    assertProviderType(input.providerType);

    const row = await db
      .insertInto("provider_configs")
      .values({
        id: crypto.randomUUID(),
        organization_id: organizationId,
        provider_type: input.providerType,
        name: input.name.trim(),
        credentials_ciphertext: encryptSecret(input.credentials),
        settings: input.settings ?? {},
        weight: input.weight ?? 1,
        is_active: input.isActive ?? true,
        daily_limit: input.dailyLimit ?? null,
        monthly_limit: input.monthlyLimit ?? null,
        created_at: new Date(),
        updated_at: new Date(),
      })
      .returning(QUERY_COLUMNS)
      .executeTakeFirstOrThrow() as any;
    return mapToResult(row);
  }

  async update(organizationId: string, id: string, input: UpdateProviderConfigInput): Promise<ProviderConfigResult> {
    await this.get(organizationId, id);

    if (input.name !== undefined && !input.name.trim()) {
      throw new ValidationError("Name cannot be empty");
    }
    if (input.credentials !== undefined && !input.credentials) {
      throw new ValidationError("Credentials cannot be empty");
    }

    const update: Record<string, unknown> = { updated_at: new Date() };
    if (input.name !== undefined) update["name"] = input.name.trim();
    if (input.credentials !== undefined) update["credentials_ciphertext"] = encryptSecret(input.credentials);
    if (input.settings !== undefined) update["settings"] = input.settings;
    if (input.weight !== undefined) update["weight"] = input.weight;
    if (input.isActive !== undefined) update["is_active"] = input.isActive;
    if (input.dailyLimit !== undefined) update["daily_limit"] = input.dailyLimit;
    if (input.monthlyLimit !== undefined) update["monthly_limit"] = input.monthlyLimit;

    const row = await db
      .updateTable("provider_configs")
      .set(update)
      .where("id", "=", id)
      .where("organization_id", "=", organizationId)
      .returning(QUERY_COLUMNS)
      .executeTakeFirstOrThrow() as any;
    return mapToResult(row);
  }

  async toggle(organizationId: string, id: string, isActive: boolean): Promise<ProviderConfigResult> {
    await this.get(organizationId, id);
    const row = await db
      .updateTable("provider_configs")
      .set({ is_active: isActive, updated_at: new Date() })
      .where("id", "=", id)
      .where("organization_id", "=", organizationId)
      .returning(QUERY_COLUMNS)
      .executeTakeFirstOrThrow() as any;
    return mapToResult(row);
  }

  async delete(organizationId: string, id: string): Promise<void> {
    await this.get(organizationId, id);
    await db
      .updateTable("provider_configs")
      .set({ deleted_at: new Date(), is_active: false, updated_at: new Date() })
      .where("id", "=", id)
      .where("organization_id", "=", organizationId)
      .execute();
  }
}
