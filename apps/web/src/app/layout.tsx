import type { Metadata } from "next";
import "./globals.css";
import { ToastProvider } from "@/components/ui/Toast";

export const metadata: Metadata = {
  title: "ResendByte — Email Service",
  description: "Email delivery platform",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className="h-full antialiased">
      <body className="min-h-full bg-bg text-text-primary font-sans">
        <ToastProvider>{children}</ToastProvider>
      </body>
    </html>
  );
}
