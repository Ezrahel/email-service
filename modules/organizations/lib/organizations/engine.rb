module Organizations
  class Engine < ::Rails::Engine
    isolate_namespace Organizations
    config.generators.api_only = true

    initializer "organizations.append_migrations" do |app|
      unless app.root.to_s.match?(root.to_s)
        config.paths["db/migrate"].expanded.each do |path|
          app.config.paths["db/migrate"] << path
        end
      end
    end
  end
end
