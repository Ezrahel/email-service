module EmailPipeline
  class TemplateRenderer < ApplicationService
    def initialize(email:)
      @email = email
    end

    def call
      return unless @email.template_id

      template = @email.template
      return unless template

      variables = extract_variables(@email)
      engine = Templates::TemplateEngine.new

      @email.update!(
        subject: engine.render(template.subject, variables),
        html_body: template.html_body ? engine.render(template.html_body, variables) : @email.html_body,
        text_body: template.text_body ? engine.render(template.text_body, variables) : @email.text_body
      )
    end

    private

    def extract_variables(email)
      # Variables can come from email.tags or associated metadata
      result = {}
      email.tags.each { |tag| result[tag["name"]] = tag["value"] } if email.tags.is_a?(Array)
      result
    end
  end
end
