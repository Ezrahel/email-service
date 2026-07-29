import { SMTPServer, type SMTPServerSession } from "smtp-server";
import { simpleParser } from "mailparser";
import { db } from "@resendbyte/database";
import { verifyAPIKey } from "@resendbyte/crypto";
import { addJob, QUEUE_NAMES } from "@resendbyte/queue";
import { StorageService } from "@resendbyte/domain";
import { env } from "@resendbyte/config";
import { logger } from "@resendbyte/logger";
import crypto from "node:crypto";
import fs from "node:fs";
import path from "node:path";
import os from "node:os";

const storageService = new StorageService();

interface AuthUser {
  apiKeyId: string;
  organizationId: string;
  environment: string;
}

let smtpServer: SMTPServer | null = null;

async function authenticate(username: string, password: string): Promise<AuthUser | null> {
  const apiKey = await db
    .selectFrom("api_keys")
    .select(["id", "organization_id", "key_digest", "key_prefix", "status", "scopes"])
    .where("id", "=", username)
    .where("status", "=", "active")
    .where((eb) => eb.or([eb("revoked_at", "is", null), eb("revoked_at", ">", new Date())]))
    .where((eb) => eb.or([eb("expires_at", "is", null), eb("expires_at", ">", new Date())]))
    .executeTakeFirst();

  if (!apiKey || !apiKey.key_digest) return null;

  const isValid = verifyAPIKey(password, apiKey.key_digest);
  if (!isValid) return null;

  const hasSendScope = apiKey.scopes?.some((s: string) => s === "email:send");
  if (!hasSendScope) return null;

  const environment = apiKey.key_prefix.startsWith("sk_test_") ? "sandbox" : "live";

  return {
    apiKeyId: apiKey.id,
    organizationId: apiKey.organization_id,
    environment,
  };
}

async function handleEmail(authUser: AuthUser, rawEmail: Buffer): Promise<void> {
  const parsed = await simpleParser(rawEmail);
  const now = new Date();

  const from = parsed.from?.value?.[0]?.address;
  const toAddresses = parsed.to?.value?.map((v: { address?: string }) => v.address).filter(Boolean) as string[] | undefined;
  const subject = parsed.subject || "(no subject)";
  const html = parsed.html as string | undefined;
  const text = parsed.text as string | undefined;

  if (!from || !toAddresses || toAddresses.length === 0) {
    logger.warn({ from, to: toAddresses }, "SMTP: missing from or to, skipping");
    return;
  }

  const originalHeaders = parsed.headers?.get("message-id")
    ? { "message-id": parsed.headers.get("message-id") }
    : {};

  for (const recipient of toAddresses) {
    const emailId = crypto.randomUUID();

    await db.insertInto("email_messages").values({
      id: emailId,
      organization_id: authUser.organizationId,
      batch_id: crypto.randomUUID(),
      from_address: from,
      to_address: recipient,
      recipient_type: "to",
      subject: subject,
      html_body: html || null,
      text_body: text || null,
      headers: originalHeaders,
      tags: ["smtp"],
      status: "queued",
      idempotency_key: null,
      reply_to: null,
      scheduled_at: null,
      environment: authUser.environment,
      created_at: now,
      updated_at: now,
      retry_count: 0,
      max_retries: 3,
    }).execute();

    if (parsed.attachments && parsed.attachments.length > 0) {
      for (const attach of parsed.attachments) {
        const filename = attach.filename || "attachment";
        const contentType = attach.contentType || "application/octet-stream";
        const content = attach.content;

        const attachmentId = crypto.randomUUID();
        const result = await storageService.upload(
          authUser.organizationId,
          filename,
          contentType,
          content
        );

        await db.insertInto("attachments").values({
          id: attachmentId,
          email_message_id: emailId,
          filename,
          content_type: contentType,
          size_bytes: content.length,
          storage_path: result.path,
          storage_provider: "s3",
          checksum: result.checksum,
          created_at: now,
        }).execute();
      }
    }

    await addJob(QUEUE_NAMES.EMAIL_CRITICAL, "send-email", {
      emailMessageId: emailId,
      organizationId: authUser.organizationId,
      environment: authUser.environment,
    });
  }

  logger.info(
    { count: toAddresses.length, from, subject, environment: authUser.environment },
    "SMTP: emails accepted"
  );
}

function getSecureContext(): { key: Buffer; cert: Buffer } | undefined {
  if (env.SMTP_TLS_KEY_PATH && env.SMTP_TLS_CERT_PATH) {
    try {
      return {
        key: fs.readFileSync(env.SMTP_TLS_KEY_PATH),
        cert: fs.readFileSync(env.SMTP_TLS_CERT_PATH),
      };
    } catch (err) {
      logger.warn({ error: String(err) }, "SMTP: failed to load TLS certs, falling back to auto-generated");
    }
  }
  return undefined;
}

export async function startSmtpServer(): Promise<void> {
  const secureContext = getSecureContext();

  const server = new SMTPServer({
    secure: false,
    disabledCommands: [],

    onConnect(session: SMTPServerSession, callback: (err?: Error | null) => void) {
      callback();
    },

    onAuth(auth: { username?: string; password?: string }, session: SMTPServerSession, callback: (err?: Error | null, response?: { user: string }) => void) {
      const username = auth.username || "";
      const password = auth.password || "";
      authenticate(username, password)
        .then((user) => {
          if (user) {
            (session as any).authUser = user;
            callback(null, { user: username });
          } else {
            callback(new Error("Authentication failed"));
          }
        })
        .catch((err) => callback(err));
    },

    onData(stream: NodeJS.ReadableStream, session: SMTPServerSession, callback: (err?: Error | null) => void) {
      const chunks: Buffer[] = [];
      stream.on("data", (chunk: Buffer) => chunks.push(chunk));
      stream.on("end", async () => {
        const raw = Buffer.concat(chunks);
        const authUser = (session as any).authUser as AuthUser | undefined;
        if (!authUser) {
          callback(new Error("Not authenticated"));
          return;
        }
        try {
          await handleEmail(authUser, raw);
          callback();
        } catch (err) {
          logger.error({ error: String(err) }, "SMTP: failed to process email");
          callback(new Error("Failed to process email"));
        }
      });
      stream.on("error", (err: Error) => {
        logger.error({ error: String(err) }, "SMTP: stream error");
        callback(err);
      });
    },
  });

  smtpServer = server;

  const portStr = env.SMTP_GATEWAY_PORTS || "587,2525";
  const ports = portStr.split(",").map((p: string) => parseInt(p.trim(), 10)).filter((p: number) => !isNaN(p));

  const listenPromises = ports.map((port) => {
    return new Promise<void>((resolve, reject) => {
      server.listen(port, () => {
        logger.info({ port }, `SMTP server listening on port ${port}`);
        resolve();
      });
      server.once("error", (err: Error) => {
        reject(err);
      });
    });
  });

  await Promise.all(listenPromises);

  server.on("error", (err: Error) => {
    logger.error({ error: String(err) }, "SMTP server error");
  });
}

export async function stopSmtpServer(): Promise<void> {
  if (smtpServer) {
    await new Promise<void>((resolve) => smtpServer!.close(() => resolve()));
    smtpServer = null;
    logger.info("SMTP server closed");
  }
}
