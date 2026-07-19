"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const zod_1 = require("zod");
const sendEmailSchema = zod_1.z.object({
    from: zod_1.z.string().email(),
    to: zod_1.z.union([zod_1.z.string().email(), zod_1.z.array(zod_1.z.string().email())]),
    subject: zod_1.z.string().min(1).max(998),
    html: zod_1.z.string().optional(),
    text: zod_1.z.string().optional(),
    replyTo: zod_1.z.string().email().optional(),
    tags: zod_1.z.array(zod_1.z.string()).optional(),
    idempotencyKey: zod_1.z.string().optional(),
});
console.log("Schema parsed successfully");
