module CatarseScripts
  class Engine < ::Rails::Engine
    isolate_namespace CatarseScripts

    config.generators do |g|
      g.test_framework :rspec
    end
  end
end
