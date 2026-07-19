class EmailSerializer < ApplicationSerializer
  attributes :id, :from, :to, :subject, :status, :html_body, :text_body,
             :headers, :tags, :reply_to, :scheduled_at,
             :sent_at, :delivered_at, :opened_at, :clicked_at,
             :created_at, :updated_at

  attribute :from do |message|
    message.from_address
  end

  attribute :to do |message|
    [message.to_address]
  end

  attribute :opened_at do |message|
    message.delivery&.opened_at
  end

  attribute :clicked_at do |message|
    message.delivery&.clicked_at
  end

  attribute :open_count do |message|
    message.delivery&.open_count || 0
  end

  attribute :click_count do |message|
    message.delivery&.click_count || 0
  end

  belongs_to :template, serializer: TemplateSerializer, optional: true
end
