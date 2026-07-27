"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { setAccessToken } from "@/lib/api";
import { api } from "@/lib/api";
import { Button } from "@/components/ui/Button";
import { Input } from "@/components/ui/Input";

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

interface LoginResponse {
  token: string;
  refreshToken: string;
  expiresAt: string;
  user: {
    id: string;
    email: string;
    firstName: string;
    lastName: string;
    organizationId: string;
  };
}

export default function LoginPage() {
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [fieldErrors, setFieldErrors] = useState<{ email?: string; password?: string }>({});

  const validate = () => {
    const errors: { email?: string; password?: string } = {};
    if (!email) errors.email = "Email is required";
    else if (!EMAIL_RE.test(email)) errors.email = "Invalid email format";
    if (!password) errors.password = "Password is required";
    else if (password.length < 8) errors.password = "Password must be at least 8 characters";
    setFieldErrors(errors);
    return Object.keys(errors).length === 0;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");
    if (!validate()) return;
    setLoading(true);
    try {
      const data = await api.post<LoginResponse>("/auth/login", { email, password });
      localStorage.setItem("token", data.token);
      localStorage.setItem("user", JSON.stringify(data.user));
      setAccessToken(data.token);
      router.push("/dashboard");
    } catch (err: any) {
      setError(err.message || "An unexpected error occurred");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="flex h-screen items-center justify-center animate-fade-in">
      <div className="glass p-8 w-full max-w-sm">
        <div className="text-center mb-6">
          <Link href="/" className="text-[32px] font-semibold tracking-tight text-text-primary no-underline">
            Mailo
          </Link>
          <p className="text-[15px] text-text-secondary mt-1">Sign in to your email dashboard</p>
        </div>
        <form onSubmit={handleSubmit} className="flex flex-col gap-4">
          <Input
            label="Email"
            type="email"
            placeholder="you@example.com"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            error={fieldErrors.email}
          />
          <Input
            label="Password"
            type="password"
            placeholder="Enter your password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            error={fieldErrors.password}
          />
          {error && <p className="text-[13px] text-danger">{error}</p>}
          <Button type="submit" loading={loading} className="w-full mt-1">
            Sign In
          </Button>
        </form>
      </div>
    </div>
  );
}
