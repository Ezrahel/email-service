import { S3Client, PutObjectCommand, GetObjectCommand, DeleteObjectCommand } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";
import crypto from "node:crypto";
import { env } from "@resendbyte/config";
import { InternalError } from "@resendbyte/errors";

export interface StoredFile {
  path: string;
  bucket: string;
  url?: string;
}

export class StorageService {
  private client: S3Client | null = null;
  private bucket: string = "";

  private getClient(): S3Client {
    if (!this.client) {
      this.client = new S3Client({
        endpoint: env.S3_ENDPOINT || "http://localhost:9000",
        region: env.S3_REGION || "us-east-1",
        credentials: {
          accessKeyId: env.S3_ACCESS_KEY || "minioadmin",
          secretAccessKey: env.S3_SECRET_KEY || "minioadmin",
        },
        forcePathStyle: true,
      });
    }
    return this.client;
  }

  private getBucket(): string {
    return env.S3_BUCKET || "email-attachments";
  }

  async upload(
    organizationId: string,
    filename: string,
    contentType: string,
    buffer: Buffer
  ): Promise<{ path: string; checksum: string; size: number }> {
    const key = `attachments/${organizationId}/${crypto.randomUUID()}/${filename}`;
    const checksum = crypto.createHash("sha256").update(buffer).digest("hex");

    try {
      const client = this.getClient();
      await client.send(new PutObjectCommand({
        Bucket: this.getBucket(),
        Key: key,
        Body: buffer,
        ContentType: contentType,
        ChecksumSHA256: checksum,
      }));

      return { path: key, checksum, size: buffer.length };
    } catch (error) {
      throw new InternalError("Failed to upload file to storage", { error: String(error) });
    }
  }

  async getSignedUrl(path: string, expiresInSeconds = 3600): Promise<string> {
    try {
      const client = this.getClient();
      const command = new GetObjectCommand({
        Bucket: this.getBucket(),
        Key: path,
      });
      return await getSignedUrl(client, command, { expiresIn: expiresInSeconds });
    } catch (error) {
      throw new InternalError("Failed to generate signed URL", { error: String(error) });
    }
  }

  async delete(path: string): Promise<void> {
    try {
      const client = this.getClient();
      await client.send(new DeleteObjectCommand({
        Bucket: this.getBucket(),
        Key: path,
      }));
    } catch (error) {
      throw new InternalError("Failed to delete file from storage", { error: String(error) });
    }
  }
}
