class UserSerializer < ApplicationSerializer
  attributes :id, :email, :first_name, :last_name, :full_name, :timezone,
             :locale, :status, :created_at, :updated_at

  attribute :full_name do |user|
    user.full_name
  end
end
