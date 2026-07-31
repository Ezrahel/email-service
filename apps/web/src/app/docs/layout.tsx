import type { Metadata } from "next";
import { DocsSidebar } from "./DocsSidebar";

export const metadata: Metadata = {
  title: "Documentation — ResendByte",
  description: "Comprehensive documentation for the ResendByte transactional email delivery platform. Learn how to send emails, manage domains, configure webhooks, and more.",
};

export default function DocsLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="flex min-h-screen">
      <DocsSidebar />
      <main className="flex-1 min-h-screen max-w-[900px] mx-auto px-8 py-10">
        {children}
      </main>
    </div>
  );
}
