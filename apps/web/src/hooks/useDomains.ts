"use client";

import { useState, useEffect, useCallback, useRef } from "react";
import { api } from "@/lib/api";

export function useDomains() {
  const [domains, setDomains] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [adding, setAdding] = useState(false);
  const [verifying, setVerifying] = useState<string | null>(null);
  const ignoreRef = useRef(false);

  const fetchDomains = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const res: any = await api.get("/domains");
      if (!ignoreRef.current) setDomains(res || []);
    } catch (e: any) {
      if (!ignoreRef.current) {
        if (e.status === 401) {
          window.location.href = "/login";
          return;
        }
        setError(e.message || "Failed to load domains");
      }
    } finally {
      if (!ignoreRef.current) setLoading(false);
    }
  }, []);

  useEffect(() => {
    ignoreRef.current = false;
    fetchDomains();
    return () => { ignoreRef.current = true; };
  }, [fetchDomains]);

  const addDomain = useCallback(async (domain: string) => {
    setAdding(true);
    try {
      await api.post("/domains", { domain });
      await fetchDomains();
    } catch (e: any) {
      if (e.status === 401) {
        window.location.href = "/login";
        return;
      }
      throw e;
    } finally {
      if (!ignoreRef.current) setAdding(false);
    }
  }, [fetchDomains]);

  const verifyDomain = useCallback(async (id: string) => {
    setVerifying(id);
    try {
      await api.post(`/domains/${id}/verify`);
      await fetchDomains();
    } catch (e: any) {
      if (e.status === 401) {
        window.location.href = "/login";
        return;
      }
      throw e;
    } finally {
      if (!ignoreRef.current) setVerifying(null);
    }
  }, [fetchDomains]);

  return { domains, loading, error, refetch: fetchDomains, addDomain, adding, verifyDomain, verifying };
}
