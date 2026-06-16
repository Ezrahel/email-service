module Webhooks
  class Engine < ::Rails::Engine
    isolate_namespace Webhooks
    config.generators.api_only = true

    initializer "webhooks.append_migrations" do |app|
      unless app.root.to_s.match?(root.to_s)
        config.paths["db/migrate"].expanded.each do |path|
          app.config.paths["db/migrate"] << path
        end
      end
    end
  end
end
