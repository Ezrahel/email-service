class Current < ActiveSupport::CurrentAttributes
  attribute :request_id, :user_id, :organization_id, :api_key_id
end
