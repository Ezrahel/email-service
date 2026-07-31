import { API_BASE } from "./constants";

interface RequestOptions extends Omit<RequestInit, "body"> {
  body?: unknown;
}

class ApiError extends Error {
  status: number;
  constructor(message: string, status: number) {
    super(message);
    this.status = status;
    this.name = "ApiError";
  }
}

async function request<T>(path: string, options: RequestOptions = {}): Promise<T> {
  const headers: Record<string, string> = {
    ...(options.headers as Record<string, string>),
  };

  if (options.body && !(options.body instanceof FormData)) {
    headers["Content-Type"] = "application/json";
  }

  const res = await fetch(`${API_BASE}${path}`, {
    ...options,
    headers,
    body:
      options.body instanceof FormData
        ? options.body
        : options.body
          ? JSON.stringify(options.body)
          : undefined,
  });

  if (res.status === 204) return undefined as T;

  const json = await res.json();

  if (!res.ok) {
    throw new ApiError(json.error?.message || json.message || "Request failed", res.status);
  }

  return json.data ?? json;
}

export const api = {
  get: <T>(path: string, opts?: RequestOptions) => request<T>(path, { ...opts, method: "GET" }),
  post: <T>(path: string, body?: unknown, opts?: RequestOptions) => request<T>(path, { ...opts, method: "POST", body }),
  delete: <T>(path: string, opts?: RequestOptions) => request<T>(path, { ...opts, method: "DELETE" }),
};

export { ApiError };
