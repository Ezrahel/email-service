"use client";

import { useState, useEffect, useMemo } from "react";
import { useRouter } from "next/navigation";
import {
  Send, CheckCircle, TrendingDown, Eye,
} from "lucide-react";
import { api } from "@/lib/api";
import { authClient } from "@/lib/auth-client";
import { Button } from "@/components/ui/Button";
import { EmptyState } from "@/components/ui/EmptyState";
import { PageShell } from "@/components/layout/PageShell";
import { StatCard } from "@/components/dashboard/StatCard";
import { ActivityChart } from "@/components/dashboard/ActivityChart";
import { ProviderBreakdownChart } from "@/components/dashboard/ProviderBreakdownChart";
import { RecentActivityTable } from "@/components/dashboard/RecentActivityTable";
import { AlertsPanel } from "@/components/dashboard/AlertsPanel";
import { DashboardSkeleton } from "@/components/dashboard/DashboardSkeleton";
import { formatNumber, formatPercentage } from "@/lib/format";

interface OverviewData {
  sent: number;
  delivered: number;
  bounced: number;
  complained: number;
  opened: number;
  clicked: number;
  deliveryRate: number;
  bounceRate: number;
  openRate: number;
  clickRate: number;
}

interface ProviderData {
  provider_type: string;
  count: number;
  delivered: number;
  bounced: number;
}

interface ActivityData {
  created_at: string;
  count: number;
}

interface AlertData {
  id: string;
  type: string;
  message: string;
  severity: string;
  created_at: string;
}

interface RecentEmail {
  id: string;
  created_at: string;
  status: string;
  recipient: string;
  subject: string;
}

interface DashboardUser {
  email?: string | null;
  firstName?: string | null;
  lastName?: string | null;
  organizationId?: string | null;
}

export default function DashboardPage() {
  const router = useRouter();

  const [overview, setOverview] = useState<OverviewData | null>(null);
  const [providers, setProviders] = useState<ProviderData[]>([]);
  const [activity, setActivity] = useState<ActivityData[]>([]);
  const [recentEmails, setRecentEmails] = useState<RecentEmail[]>([]);
  const [alerts, setAlerts] = useState<AlertData[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const { data: session } = authClient.useSession();
  const userInfo = (session?.user ?? null) as DashboardUser | null;

  const fetchAll = async () => {
    setLoading(true);
    setError("");
    try {
      const [overviewData, providersData, activityData, alertsData] = await Promise.all([
        api.get<OverviewData>("/analytics/overview"),
        api.get<ProviderData[]>("/dashboard/providers"),
        api.get<ActivityData[]>("/dashboard/activity"),
        api.get<AlertData[]>("/dashboard/alerts"),
      ]);

      setOverview(overviewData);
      setProviders(providersData || []);
      setActivity(activityData || []);
      setAlerts(alertsData || []);

      let recent: RecentEmail[] = [];
      try {
        recent = await api.get<RecentEmail[]>("/emails?per_page=20");
      } catch {
        recent = [];
      }
      setRecentEmails(recent);
    } catch (err: any) {
      if (err.status === 401) {
        router.replace("/login");
        return;
      }
      setError(err.message || "Failed to load dashboard data");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchAll();
  }, []);

  const subtitle = useMemo(() => {
    if (!userInfo) return "Welcome back";
    const name = userInfo.firstName || "";
    const org = userInfo.organizationId || "";
    if (name && org) return `Welcome back, ${name} · ${org}`;
    if (name) return `Welcome back, ${name}`;
    return "Welcome back";
  }, [userInfo]);

  if (loading) {
    return (
      <PageShell title="Dashboard" subtitle={subtitle}>
        <DashboardSkeleton />
      </PageShell>
    );
  }

  if (error) {
    return (
      <PageShell title="Dashboard" subtitle={subtitle}>
        <div className="glass p-8 flex flex-col items-center text-center max-w-md mx-auto">
          <p className="text-danger text-[15px] mb-4">{error}</p>
          <Button variant="secondary" onClick={fetchAll}>Retry</Button>
        </div>
      </PageShell>
    );
  }

  if (!overview) {
    return (
      <PageShell title="Dashboard" subtitle={subtitle}>
        <EmptyState
          title="Welcome to ResendByte"
          description="Your email dashboard is ready. Once you start sending emails, your stats will appear here."
        />
      </PageShell>
    );
  }

  return (
    <PageShell title="Dashboard" subtitle={subtitle}>
      <div className="flex flex-col gap-5">
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          <StatCard icon={<Send className="h-5 w-5" />} label="Emails Sent" value={formatNumber(overview.sent)} delay={0} />
          <StatCard icon={<CheckCircle className="h-5 w-5" />} label="Delivered" value={formatNumber(overview.delivered)} delay={50} />
          <StatCard icon={<TrendingDown className="h-5 w-5" />} label="Bounce Rate" value={formatPercentage(overview.bounceRate)} delay={100} />
          <StatCard icon={<Eye className="h-5 w-5" />} label="Open Rate" value={formatPercentage(overview.openRate)} delay={150} />
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-5">
          <div className="lg:col-span-2">
            <ActivityChart data={activity} />
          </div>
          <div>
            <ProviderBreakdownChart data={providers} />
          </div>
        </div>

        {recentEmails.length > 0 && <RecentActivityTable data={recentEmails} />}

        <AlertsPanel data={alerts} />
      </div>
    </PageShell>
  );
}
