export interface User {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  organizationId: string | null;
}

export interface LoginResponse {
  token: string;
  refreshToken: string;
  expiresAt: string;
  user: User;
}

export interface PaginatedResponse<T> {
  data: T[];
  meta: {
    page: number;
    perPage: number;
    total: number;
    pages: number;
  };
}

export interface EmailMessage {
  id: string;
  organization_id: string;
  from_address: string;
  to_address: string;
  recipient_type: string;
  subject: string;
  html_body: string | null;
  text_body: string | null;
  status: "queued" | "sending" | "delivered" | "bounced" | "opened" | "clicked" | "complained";
  tags: string[];
  created_at: string;
  updated_at: string;
  deliveries?: Delivery[];
}

export interface Delivery {
  id: string;
  email_message_id: string;
  provider_type: string;
  status: string;
  response_code: string;
  attempt_number: number;
  delivered_at: string | null;
  created_at: string;
}

export interface Domain {
  id: string;
  organization_id: string;
  domain: string;
  status: "pending" | "verified" | "failed";
  dkim_verified: boolean;
  spf_verified: boolean;
  dmarc_verified: boolean;
  dkim_selector: string;
  tracking_enabled: boolean;
  created_at: string;
}

export interface Template {
  id: string;
  name: string;
  slug: string;
  created_at: string;
}

export interface ApiKey {
  id: string;
  name: string;
  key_prefix: string;
  key_last_chars: string;
  scopes: string[];
  status: "active" | "revoked";
  expires_at: string | null;
  last_used_at: string | null;
  created_at: string;
}

export interface Webhook {
  id: string;
  url: string;
  events: string[];
  status: "active" | "deleted";
  failure_count: number;
  created_at: string;
}

export interface AnalyticsOverview {
  period: string;
  sent: number;
  delivered: number;
  bounced: number;
  complained: number;
  opened: number;
  clicked: number;
  deliveryRate: number;
  bounceRate: number;
  openRate: number;
  clickRate: number;
}

export interface ProviderBreakdown {
  provider_type: string;
  count: number;
  delivered: number;
  bounced: number;
}

export interface ActivityPoint {
  created_at: string;
  count: number;
}

export interface DashboardUsage {
  sentThisMonth: number;
  limit: number;
  monthStart: string;
}
