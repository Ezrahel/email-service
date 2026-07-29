export class HttpClient {
  private baseUrl: string;
  private apiKey: string;

  constructor(options: { apiKey: string; baseUrl?: string }) {
    this.apiKey = options.apiKey;
    this.baseUrl = (options.baseUrl || "https://api.resendbyte.com").replace(/\/+$/, "");
  }

  async request<T>(method: string, path: string, body?: unknown): Promise<T> {
    const url = `${this.baseUrl}${path}`;
    const headers: Record<string, string> = {
      Authorization: `Bearer ${this.apiKey}`,
    };

    if (body !== undefined) {
      headers["Content-Type"] = "application/json";
    }

    const response = await fetch(url, {
      method,
      headers,
      body: body !== undefined ? JSON.stringify(body) : undefined,
    });

    if (response.status === 204) {
      return undefined as T;
    }

    const json: any = await response.json();

    if (!response.ok) {
      const message = json?.error?.message || json?.message || `HTTP ${response.status}`;
      const err = new Error(message) as Error & { status: number; code?: string };
      err.status = response.status;
      err.code = json?.error?.code;
      throw err;
    }

    return (json?.data ?? json) as T;
  }

  get<T>(path: string): Promise<T> {
    return this.request<T>("GET", path);
  }

  post<T>(path: string, body?: unknown): Promise<T> {
    return this.request<T>("POST", path, body);
  }

  delete<T>(path: string): Promise<T> {
    return this.request<T>("DELETE", path);
  }

  async uploadAttachment(filename: string, contentType: string, buffer: Buffer): Promise<{ id: string; filename: string; contentType: string; size: number }> {
    const url = `${this.baseUrl}/attachments`;
    const formData = new FormData();
    const blob = new Blob([buffer], { type: contentType });
    formData.append("file", blob, filename);

    const response = await fetch(url, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${this.apiKey}`,
      },
      body: formData,
    });

    const json: any = await response.json();

    if (!response.ok) {
      const message = json?.error?.message || json?.message || `HTTP ${response.status}`;
      throw new Error(message);
    }

    return json?.data;
  }
}
