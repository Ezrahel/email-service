class DnsRecordSerializer < ApplicationSerializer
  attributes :id, :record_type, :name, :value, :ttl, :status, :is_verified,
             :last_checked_at, :expected_value, :actual_value,
             :created_at, :updated_at
end
