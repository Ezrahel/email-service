import type { FastifyInstance } from "fastify";
import { sql } from "kysely";
import { db } from "@resendbyte/database";
import { logger } from "@resendbyte/logger";

const TRANSPARENT_GIF = Buffer.from("R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7", "base64");

export async function trackingRoutes(app: FastifyInstance): Promise<void> {
  app.get("/track/open/:messageId.png", async (request, reply) => {
    const { messageId } = request.params as { messageId: string };

    try {
      await db.updateTable("email_metrics")
        .set({
          is_opened: true,
          opened_at: new Date(),
          open_count: sql`open_count + 1`,
          updated_at: new Date(),
        })
        .where("email_message_id", "=", messageId)
        .execute();
    } catch (error) {
      logger.error({ error: String(error), messageId }, "Failed to record open event");
    }

    reply.header("Content-Type", "image/gif");
    reply.header("Cache-Control", "no-store, no-cache, must-revalidate");
    reply.header("Pragma", "no-cache");
    reply.header("Expires", "0");
    reply.status(200).send(TRANSPARENT_GIF);
  });

  app.get("/track/click/:messageId", async (request, reply) => {
    const { messageId } = request.params as { messageId: string };
    const { redirect } = request.query as { redirect?: string };

    try {
      await db.updateTable("email_metrics")
        .set({
          is_clicked: true,
          clicked_at: new Date(),
          click_count: sql`click_count + 1`,
          updated_at: new Date(),
        })
        .where("email_message_id", "=", messageId)
        .execute();
    } catch (error) {
      logger.error({ error: String(error), messageId }, "Failed to record click event");
    }

    const redirectUrl = redirect || "https://example.com";
    reply.status(302).redirect(redirectUrl);
  });
}
