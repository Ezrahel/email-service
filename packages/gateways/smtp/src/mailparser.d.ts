declare module "mailparser" {
  import type { Readable } from "node:stream";

  interface Attachment {
    filename?: string;
    contentType?: string;
    content: Buffer;
    size: number;
  }

  interface ParsedMail {
    from?: { value?: { address?: string }[] };
    to?: { value?: { address?: string }[] };
    subject?: string;
    html?: string | boolean;
    text?: string;
    attachments?: Attachment[];
    headers?: Map<string, string>;
  }

  export function simpleParser(
    source: Buffer | string | Readable,
    options?: any
  ): Promise<ParsedMail>;

  export type AddressObject = {
    value?: { address?: string }[];
  };
}
