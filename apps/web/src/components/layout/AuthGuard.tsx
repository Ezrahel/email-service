"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { setAccessToken, getAccessToken } from "@/lib/api";

interface AuthGuardProps {
  children: React.ReactNode;
}

export function AuthGuard({ children }: AuthGuardProps) {
  const router = useRouter();
  const [checking, setChecking] = useState(true);

  useEffect(() => {
    const token = localStorage.getItem("token");
    if (token) {
      setAccessToken(token);
      setChecking(false);
    } else {
      router.replace("/login");
    }
  }, [router]);

  if (checking) {
    return (
      <div className="flex h-screen items-center justify-center">
        <div className="flex flex-col items-center gap-3">
          <div className="h-8 w-8 animate-spin rounded-full border-2 border-accent border-t-transparent" />
          <p className="text-sm text-text-secondary">Loading...</p>
        </div>
      </div>
    );
  }

  return <>{children}</>;
}
