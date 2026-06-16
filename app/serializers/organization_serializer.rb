class OrganizationSerializer < ApplicationSerializer
  attributes :id, :name, :slug, :plan, :status, :monthly_email_quota,
             :monthly_email_sent, :ip_allowlist_enabled, :ip_allowlist,
             :created_at, :updated_at
end
