"use client";

import { useState, useEffect, useCallback } from "react";
import { api, setAccessToken } from "@/lib/api";

interface User {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  organizationId: string | null;
}

interface LoginResponse {
  token: string;
  user: User;
}

export function useAuth() {
  const [user, setUser] = useState<User | null>(null);
  const [token, setToken] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (typeof window === "undefined") return;
    const storedToken = localStorage.getItem("token");
    const storedUser = localStorage.getItem("user");
    if (storedToken && storedUser) {
      try {
        const parsed = JSON.parse(storedUser);
        setToken(storedToken);
        setUser(parsed);
        setAccessToken(storedToken);
      } catch {
        localStorage.removeItem("token");
        localStorage.removeItem("user");
      }
    }
  }, []);

  const login = useCallback(async (email: string, password: string) => {
    setLoading(true);
    setError(null);
    try {
      const data = await api.post<LoginResponse>("/auth/login", { email, password });
      localStorage.setItem("token", data.token);
      localStorage.setItem("user", JSON.stringify(data.user));
      setAccessToken(data.token);
      setToken(data.token);
      setUser(data.user);
    } catch (e: any) {
      setError(e.message || "Login failed");
      throw e;
    } finally {
      setLoading(false);
    }
  }, []);

  const logout = useCallback(() => {
    localStorage.removeItem("token");
    localStorage.removeItem("user");
    setAccessToken(null);
    setToken(null);
    setUser(null);
    window.location.href = "/login";
  }, []);

  return { user, token, login, logout, loading, error };
}
