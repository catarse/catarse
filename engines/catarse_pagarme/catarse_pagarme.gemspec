# encoding: utf-8
$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "catarse_pagarme/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "catarse_pagarme"
  s.version     = CatarsePagarme::VERSION
  s.authors     = ["Antônio Roberto Silva", "Diogo Biazus"]
  s.email       = ["forevertonny@gmail.com", "diogob@gmail.com"]
  s.homepage    = "https://catarse.me"
  s.summary     = "Integration with Pagar.me"
  s.description = "Pagar.me engine for catarse"

  s.files      = `git ls-files`.split($\)
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  s.add_dependency "rails"
  s.add_dependency "pagarme", "2.1.4"
  s.add_dependency "konduto-ruby", "2.1.0"
  s.add_dependency "weekdays", ">= 1.0.2"
  s.add_dependency "sidekiq"
  s.add_dependency "sentry-raven"

  s.add_development_dependency "rspec-rails", "~> 3.3"
  s.add_development_dependency "factory_girl_rails"
  s.add_development_dependency "pg"
  s.add_development_dependency "database_cleaner"
end
