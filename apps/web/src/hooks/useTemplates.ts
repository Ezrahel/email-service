"use client";

import { useState, useEffect, useCallback, useRef } from "react";
import { api } from "@/lib/api";

export function useTemplates(page: number, perPage: number) {
  const [data, setData] = useState<any[]>([]);
  const [meta, setMeta] = useState({ page: 1, perPage: 20, total: 0, pages: 0 });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const ignoreRef = useRef(false);

  const fetchTemplates = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const params = new URLSearchParams({ page: String(page), perPage: String(perPage) });
      const res: any = await api.get(`/templates?${params}`);
      if (!ignoreRef.current) {
        setData(res.data || []);
        setMeta(res.meta || { page, perPage, total: 0, pages: 0 });
      }
    } catch (e: any) {
      if (!ignoreRef.current) {
        if (e.status === 401) {
          window.location.href = "/login";
          return;
        }
        setError(e.message || "Failed to load templates");
      }
    } finally {
      if (!ignoreRef.current) setLoading(false);
    }
  }, [page, perPage]);

  useEffect(() => {
    ignoreRef.current = false;
    fetchTemplates();
    return () => { ignoreRef.current = true; };
  }, [fetchTemplates]);

  return { data, meta, loading, error, refetch: fetchTemplates };
}

export function useCreateTemplate() {
  const [creating, setCreating] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const ignoreRef = useRef(false);

  const create = useCallback(async (body: { name: string; subject: string; htmlBody: string; textBody?: string }) => {
    setCreating(true);
    setError(null);
    try {
      const result = await api.post("/templates", body);
      return result;
    } catch (e: any) {
      if (!ignoreRef.current) {
        if (e.status === 401) {
        window.location.href = "/login";
        return;
      }
      setError(e.message || "Failed to create template");
      }
      throw e;
    } finally {
      if (!ignoreRef.current) setCreating(false);
    }
  }, []);

  useEffect(() => {
    return () => { ignoreRef.current = true; };
  }, []);

  return { create, creating, error };
}
