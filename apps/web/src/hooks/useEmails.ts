"use client";

import { useState, useEffect, useCallback, useRef } from "react";
import { api } from "@/lib/api";

export function useEmails(page: number, perPage: number, status?: string) {
  const [data, setData] = useState<any[]>([]);
  const [meta, setMeta] = useState({ page: 1, perPage: 20, total: 0, pages: 0 });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const ignoreRef = useRef(false);

  const fetchEmails = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const params = new URLSearchParams({ page: String(page), perPage: String(perPage) });
      if (status) params.set("status", status);
      const res: any = await api.get(`/emails?${params}`);
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
        setError(e.message || "Failed to load emails");
      }
    } finally {
      if (!ignoreRef.current) setLoading(false);
    }
  }, [page, perPage, status]);

  useEffect(() => {
    ignoreRef.current = false;
    fetchEmails();
    return () => { ignoreRef.current = true; };
  }, [fetchEmails]);

  return { data, meta, loading, error, refetch: fetchEmails };
}

export function useEmail(id: string) {
  const [email, setEmail] = useState<any | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const ignoreRef = useRef(false);

  const fetchEmail = useCallback(async () => {
    if (!id) return;
    setLoading(true);
    setError(null);
    try {
      const res = await api.get(`/emails/${id}`);
      if (!ignoreRef.current) setEmail(res);
    } catch (e: any) {
      if (!ignoreRef.current) {
        if (e.status === 401) {
          window.location.href = "/login";
          return;
        }
        setError(e.message || "Failed to load email");
      }
    } finally {
      if (!ignoreRef.current) setLoading(false);
    }
  }, [id]);

  useEffect(() => {
    ignoreRef.current = false;
    fetchEmail();
    return () => { ignoreRef.current = true; };
  }, [fetchEmail]);

  return { email, loading, error };
}

export function useSendEmail() {
  const [sending, setSending] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const ignoreRef = useRef(false);

  const send = useCallback(async (body: any) => {
    setSending(true);
    setError(null);
    try {
      const result = await api.post("/emails", body);
      return result;
    } catch (e: any) {
      if (!ignoreRef.current) {
        if (e.status === 401) {
        window.location.href = "/login";
        return;
      }
      setError(e.message || "Failed to send email");
      }
      throw e;
    } finally {
      if (!ignoreRef.current) setSending(false);
    }
  }, []);

  useEffect(() => {
    return () => { ignoreRef.current = true; };
  }, []);

  return { send, sending, error };
}
