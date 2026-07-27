import { db } from "../index.js";
import type { DB, User, Organization, APIKey, Domain, Template, EmailMessage, Delivery, Membership, Webhook } from "../types.js";

export async function findUserByEmail(email: string): Promise<User | undefined> {
  return db.selectFrom("users").selectAll().where("email", "=", email).where("deleted_at", "is", null).executeTakeFirst();
}

export async function findUserById(id: string): Promise<User | undefined> {
  return db.selectFrom("users").selectAll().where("id", "=", id).where("deleted_at", "is", null).executeTakeFirst();
}

export async function findOrganizationById(id: string): Promise<Organization | undefined> {
  return db.selectFrom("organizations").selectAll().where("id", "=", id).where("deleted_at", "is", null).executeTakeFirst();
}

export async function findActiveMembership(userId: string, organizationId: string): Promise<Membership | undefined> {
  return db.selectFrom("memberships").selectAll().where("user_id", "=", userId).where("organization_id", "=", organizationId).where("status", "=", "active").executeTakeFirst();
}

export async function findUserMemberships(userId: string): Promise<Membership[]> {
  return db.selectFrom("memberships").selectAll().where("user_id", "=", userId).where("status", "=", "active").execute();
}

export async function findAPIKeyByDigest(digest: string): Promise<(APIKey & { organization: Organization | undefined }) | undefined> {
  const key = await db.selectFrom("api_keys").selectAll().where("key_digest", "=", digest).where("status", "=", "active").where("deleted_at", "is", null).executeTakeFirst();
  if (!key) return;
  const org = await findOrganizationById(key.organization_id);
  return { ...key, organization: org };
}

export async function findAPIKeysByOrganization(organizationId: string): Promise<APIKey[]> {
  return db.selectFrom("api_keys").selectAll().where("organization_id", "=", organizationId).where("deleted_at", "is", null).execute();
}

export async function findDomainsByOrganization(organizationId: string): Promise<Domain[]> {
  return db.selectFrom("domains").selectAll().where("organization_id", "=", organizationId).where("deleted_at", "is", null).execute();
}

export async function findDomainById(id: string): Promise<Domain | undefined> {
  return db.selectFrom("domains").selectAll().where("id", "=", id).where("deleted_at", "is", null).executeTakeFirst();
}

export async function findTemplatesByOrganization(organizationId: string): Promise<Template[]> {
  return db.selectFrom("templates").selectAll().where("organization_id", "=", organizationId).where("deleted_at", "is", null).execute();
}

export async function findTemplateById(id: string): Promise<Template | undefined> {
  return db.selectFrom("templates").selectAll().where("id", "=", id).where("deleted_at", "is", null).executeTakeFirst();
}

export async function findEmailsByOrganization(
  organizationId: string,
  options: { limit?: number; offset?: number; status?: string } = {}
): Promise<EmailMessage[]> {
  let query = db.selectFrom("email_messages").selectAll().where("organization_id", "=", organizationId).where("deleted_at", "is", null);
  if (options.status) query = query.where("status", "=", options.status);
  return query.orderBy("created_at", "desc").limit(options.limit ?? 50).offset(options.offset ?? 0).execute();
}

export async function findEmailById(id: string): Promise<EmailMessage | undefined> {
  return db.selectFrom("email_messages").selectAll().where("id", "=", id).where("deleted_at", "is", null).executeTakeFirst();
}

export async function findDeliveriesByEmail(emailMessageId: string): Promise<Delivery[]> {
  return db.selectFrom("deliveries").selectAll().where("email_message_id", "=", emailMessageId).execute();
}

export async function findWebhooksByOrganization(organizationId: string): Promise<Webhook[]> {
  return db.selectFrom("webhooks").selectAll().where("organization_id", "=", organizationId).where("deleted_at", "is", null).execute();
}

export async function findWebhookById(id: string): Promise<Webhook | undefined> {
  return db.selectFrom("webhooks").selectAll().where("id", "=", id).where("deleted_at", "is", null).executeTakeFirst();
}

export async function incrementOrganizationEmailCount(organizationId: string): Promise<void> {
  await db.updateTable("organizations").set((eb) => ({ emails_sent_this_month: eb("emails_sent_this_month", "+", 1) })).where("id", "=", organizationId).execute();
}
