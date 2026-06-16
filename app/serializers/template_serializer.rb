class TemplateSerializer < ApplicationSerializer
  attributes :id, :name, :slug, :description, :subject, :html_body, :text_body,
             :variables, :is_active, :version_count, :created_at, :updated_at
end
