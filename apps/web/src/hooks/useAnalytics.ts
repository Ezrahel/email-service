"use client";

import { useState, useEffect, useCallback, useRef } from "react";
import { api, setAccessToken } from "@/lib/api";

export function useAnalytics() {
  const [overview, setOverview] = useState<any | null>(null);
  const [providers, setProviders] = useState<any[]>([]);
  const [activity, setActivity] = useState<any[]>([]);
  const [alerts, setAlerts] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const ignoreRef = useRef(false);

  const fetchAll = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const [overviewData, providersData, activityData, alertsData] = await Promise.all([
        api.get<any>("/analytics/overview"),
        api.get<any[]>("/dashboard/providers"),
        api.get<any[]>("/dashboard/activity"),
        api.get<any[]>("/dashboard/alerts"),
      ]);
      if (!ignoreRef.current) {
        setOverview(overviewData);
        setProviders(providersData || []);
        setActivity(activityData || []);
        setAlerts(alertsData || []);
      }
    } catch (e: any) {
      if (!ignoreRef.current) {
        if (e.status === 401) {
          localStorage.removeItem("token");
          setAccessToken(null);
          window.location.href = "/login";
          return;
        }
        setError(e.message || "Failed to load analytics");
      }
    } finally {
      if (!ignoreRef.current) setLoading(false);
    }
  }, []);

  useEffect(() => {
    ignoreRef.current = false;
    fetchAll();
    return () => { ignoreRef.current = true; };
  }, [fetchAll]);

  return { overview, providers, activity, alerts, loading, error, refetch: fetchAll };
}
