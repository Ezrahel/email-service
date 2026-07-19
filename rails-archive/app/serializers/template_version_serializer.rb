class TemplateVersionSerializer < ApplicationSerializer
  attributes :id, :version, :subject, :html_body, :text_body, :variables,
             :change_notes, :created_at, :updated_at

  belongs_to :created_by, serializer: UserSerializer, optional: true
end
