"use client";

import { useState, useEffect, useCallback, useRef } from "react";
import { api, setAccessToken } from "@/lib/api";

export function useApiKeys() {
  const [keys, setKeys] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [creating, setCreating] = useState(false);
  const [revoking, setRevoking] = useState(false);
  const ignoreRef = useRef(false);

  const fetchKeys = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const res: any = await api.get("/api-keys");
      if (!ignoreRef.current) setKeys(res || []);
    } catch (e: any) {
      if (!ignoreRef.current) {
        if (e.status === 401) {
          localStorage.removeItem("token");
          setAccessToken(null);
          window.location.href = "/login";
          return;
        }
        setError(e.message || "Failed to load API keys");
      }
    } finally {
      if (!ignoreRef.current) setLoading(false);
    }
  }, []);

  useEffect(() => {
    ignoreRef.current = false;
    fetchKeys();
    return () => { ignoreRef.current = true; };
  }, [fetchKeys]);

  const createKey = useCallback(async (body: { name: string; scopes: string[]; expiresAt?: string }) => {
    setCreating(true);
    try {
      const result = await api.post("/api-keys", body);
      await fetchKeys();
      return result;
    } catch (e: any) {
      if (e.status === 401) {
        localStorage.removeItem("token");
        setAccessToken(null);
        window.location.href = "/login";
        return;
      }
      throw e;
    } finally {
      if (!ignoreRef.current) setCreating(false);
    }
  }, [fetchKeys]);

  const revokeKey = useCallback(async (id: string) => {
    setRevoking(true);
    try {
      await api.delete(`/api-keys/${id}`);
      await fetchKeys();
    } catch (e: any) {
      if (e.status === 401) {
        localStorage.removeItem("token");
        setAccessToken(null);
        window.location.href = "/login";
        return;
      }
      throw e;
    } finally {
      if (!ignoreRef.current) setRevoking(false);
    }
  }, [fetchKeys]);

  return { keys, loading, error, refetch: fetchKeys, createKey, creating, revokeKey, revoking };
}
