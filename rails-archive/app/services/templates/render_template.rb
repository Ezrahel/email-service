module Templates
  class RenderTemplate < ApplicationService
    def initialize(template:, variables: {})
      @template = template
      @variables = variables.with_indifferent_access
    end

    def call
      engine = TemplateEngine.new

      {
        subject: engine.render(@template.subject, @variables),
        html: @template.html_body ? engine.render(@template.html_body, @variables) : nil,
        text: @template.text_body ? engine.render(@template.text_body, @variables) : nil
      }
    end
  end

  class TemplateEngine
    def render(template, variables)
      result = template.dup

      variables.each do |key, value|
        result = result.gsub("{{ #{key} }}", value.to_s)
        result = result.gsub("{{#{key}}}", value.to_s)
      end

      result
    end
  end
end
