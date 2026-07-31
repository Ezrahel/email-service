"use client";

import { useState, useEffect, useCallback, useRef } from "react";
import { api } from "@/lib/api";

export function useWebhooks() {
  const [webhooks, setWebhooks] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [creating, setCreating] = useState(false);
  const [deleting, setDeleting] = useState(false);
  const ignoreRef = useRef(false);

  const fetchWebhooks = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const res: any = await api.get("/webhooks");
      if (!ignoreRef.current) setWebhooks(res || []);
    } catch (e: any) {
      if (!ignoreRef.current) {
        if (e.status === 401) {
          window.location.href = "/login";
          return;
        }
        setError(e.message || "Failed to load webhooks");
      }
    } finally {
      if (!ignoreRef.current) setLoading(false);
    }
  }, []);

  useEffect(() => {
    ignoreRef.current = false;
    fetchWebhooks();
    return () => { ignoreRef.current = true; };
  }, [fetchWebhooks]);

  const createWebhook = useCallback(async (body: { url: string; events: string[]; secret?: string }) => {
    setCreating(true);
    try {
      await api.post("/webhooks", body);
      await fetchWebhooks();
    } catch (e: any) {
      if (e.status === 401) {
        window.location.href = "/login";
        return;
      }
      throw e;
    } finally {
      if (!ignoreRef.current) setCreating(false);
    }
  }, [fetchWebhooks]);

  const deleteWebhook = useCallback(async (id: string) => {
    setDeleting(true);
    try {
      await api.delete(`/webhooks/${id}`);
      await fetchWebhooks();
    } catch (e: any) {
      if (e.status === 401) {
        window.location.href = "/login";
        return;
      }
      throw e;
    } finally {
      if (!ignoreRef.current) setDeleting(false);
    }
  }, [fetchWebhooks]);

  return { webhooks, loading, error, refetch: fetchWebhooks, createWebhook, creating, deleteWebhook, deleting };
}
