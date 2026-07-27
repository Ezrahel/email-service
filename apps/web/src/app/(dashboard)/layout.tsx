"use client";

import { useState } from "react";
import { AuthGuard } from "@/components/layout/AuthGuard";
import { Sidebar } from "@/components/layout/Sidebar";
import { TopBar } from "@/components/layout/TopBar";

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  const [collapsed, setCollapsed] = useState(false);

  return (
    <AuthGuard>
      <div className="flex min-h-screen">
        <Sidebar collapsed={collapsed} onToggle={() => setCollapsed(!collapsed)} />
        <div className="flex-1 flex flex-col min-h-screen">
          <TopBar />
          <main className="flex-1 p-6 pt-4">{children}</main>
        </div>
      </div>
    </AuthGuard>
  );
}
