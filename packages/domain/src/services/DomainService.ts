import { db } from "@resendbyte/database";
import { ValidationError, ConflictError, NotFoundError } from "@resendbyte/errors";
import crypto from "node:crypto";

export interface DomainResult {
  id: string; organization_id: string; domain: string; status: string;
  dkim_verified: boolean; spf_verified: boolean; dmarc_verified: boolean;
  created_at: Date;
}

export class DomainService {
  async list(organizationId: string): Promise<DomainResult[]> {
    return db.selectFrom("domains").selectAll().where("organization_id", "=", organizationId).where("deleted_at", "is", null).orderBy("created_at", "desc").execute();
  }

  async get(organizationId: string, id: string): Promise<DomainResult> {
    const domain = await db.selectFrom("domains").selectAll().where("id", "=", id).where("organization_id", "=", organizationId).where("deleted_at", "is", null).executeTakeFirst();
    if (!domain) throw new NotFoundError("Domain");
    return domain;
  }

  async create(organizationId: string, domainName: string): Promise<DomainResult> {
    const domainRegex = /^(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z]{2,}$/i;
    if (!domainRegex.test(domainName)) throw new ValidationError("Invalid domain format");
    const normalized = domainName.toLowerCase();
    const existing = await db.selectFrom("domains").select("id").where("domain", "=", normalized).where("organization_id", "=", organizationId).executeTakeFirst();
    if (existing) throw new ConflictError("Domain already exists");
    return db.insertInto("domains").values({
      id: crypto.randomUUID(), organization_id: organizationId, domain: normalized,
      status: "pending", dkim_selector: "mailo",
      dkim_private_key_ciphertext: null, dkim_public_key: null,
      dkim_verified: false, spf_verified: false, dmarc_verified: false,
      tracking_enabled: false, created_at: new Date(), updated_at: new Date(),
    }).returningAll().executeTakeFirstOrThrow();
  }
}
