"use client";

import { useCallback } from "react";
import { authClient } from "@/lib/auth-client";

export function useAuth() {
  const { data, isPending, error } = authClient.useSession();
  const user = data?.user ?? null;

  const login = useCallback(async (email: string, password: string) => {
    const res = await authClient.signIn.email({ email, password });
    if (res.error) {
      throw new Error(res.error.message || "Login failed");
    }
    return res.data;
  }, []);

  const logout = useCallback(async () => {
    await authClient.signOut();
    window.location.href = "/login";
  }, []);

  return { user, login, logout, loading: isPending, error: error ? String(error) : null };
}
