class DomainSerializer < ApplicationSerializer
  attributes :id, :domain, :status, :region, :is_verified, :verified_at,
             :dkim_selector, :spf_record, :dkim_record, :dmarc_record,
             :mx_record, :tracking_subdomain, :is_bounce_domain,
             :created_at, :updated_at

  has_many :dns_records, serializer: DnsRecordSerializer
end
