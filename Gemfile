if RUBY_VERSION =~ /1.9/
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end

source 'http://rubygems.org'
source 'http://gems.github.com'
gem 'rails', '3.0.3'
gem 'rake', '0.8.7'
gem 'haml'
gem 'slim'
gem 'sass', '3.1.7'
gem 'compass', '0.11.5'
gem 'omniauth', '0.1.6'
gem 'formtastic', '~> 1.1.0'
gem 'validation_reflection'
gem 'inherited_resources', '= 1.1.2'
gem 'maxim-sexy_pg_constraints'
gem 'spectator-validates_email', :require => 'validates_email'
gem 'vimeo'
gem 'wirble'
gem "on_the_spot"
gem 'unicorn'
gem 'mailee', '0.5.4', :git => 'https://github.com/danielweinmann/mailee-api.git'
gem 'will_paginate', ">= 3.0.pre2"
gem 'weekdays'
gem 'moip', :git => 'https://github.com/danielweinmann/moip-ruby.git'
gem 'paypal-express', :require => 'paypal'
gem 'brcep'
gem "meta_search"
gem "RedCloth"
gem "auto_html", '>= 1.3.5'
gem "acts_as_commentable"
gem 'mustache'
gem 'unicode'
gem 'routing-filter'
gem 'http_accept_language'
gem 'cancan'
gem 'activeadmin', "= 0.2.2"
gem 'carrierwave', :git => 'https://github.com/jnicklas/carrierwave.git'
gem 'rmagick'
gem 'fog'
gem 'capybara', ">= 0.4.0"
gem 'enumerate_it'

group :test, :development do
  gem 'annotate'
  gem 'launchy'
  gem 'database_cleaner'
  gem 'steak', "~> 1.1.0"
  gem 'rspec-rails', "~> 2.0.1"
  gem 'rcov'
  gem 'factory_girl_rails'
  gem 'mocha'
end

group :test do
  gem 'shoulda'
end

# if you want use capybara-webkit, compile QT and be happy :)
# group :test do
#   gem 'capybara-webkit', "0.6.1"
# end

# Putting pg to the end because of a weird bug with Lion, pg and openssl
gem 'pg'
