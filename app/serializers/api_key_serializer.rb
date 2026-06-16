class ApiKeySerializer < ApplicationSerializer
  attributes :id, :name, :key_prefix, :scopes, :allowed_ips, :status,
             :expires_at, :last_used_at, :created_at, :updated_at

  attribute :key do |key|
    nil
  end
end
