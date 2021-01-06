require_relative "lib/catarse_scripts/version"

Gem::Specification.new do |spec|
  spec.name        = "catarse_scripts"
  spec.version     = CatarseScripts::VERSION
  spec.authors     = ["stephannv", "gabrielras"]
  spec.email       = ["3025661+stephannv@users.noreply.github.com", "gabrielras12@hotmail.com"]
  spec.homepage    = "https://catarse.me"
  spec.summary     = "Engine to run scripts on catarse"
  spec.description = "Engine to run scripts on catarse"
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/catarse/catarse"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", "~> 6.1.0.rc1"
  spec.add_dependency "slim"
  spec.add_dependency "ransack"
  spec.add_dependency "pagy"

  spec.add_development_dependency "byebug"
  spec.add_development_dependency "factory_bot_rails"
  spec.add_development_dependency "rails-controller-testing"
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "sentry-raven"
  spec.add_development_dependency "shoulda-matchers"
  spec.add_development_dependency "sidekiq-status"
end
