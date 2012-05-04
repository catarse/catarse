if RUBY_VERSION =~ /1.9/
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end

source 'http://rubygems.org'
source 'http://gems.github.com'

gem 'rails', '3.2.3'
gem 'rake', '0.9.2.2'

# Database [Putting pg to the end because of a weird bug with Lion, pg and openssl]
gem 'pg'
gem 'foreigner'

# Frontend stuff
gem 'jquery-rails'
gem 'haml'
gem 'slim'
gem 'slim-rails'
gem 'mustache'

# Authentication and Authorization
gem "omniauth", '1.0.0'
gem 'omniauth-google'
gem "devise", '1.5.3'
gem 'cancan'

gem 'rails_autolink', '~> 1.0.7'

# Tools
gem 'feedzirra'
gem 'formtastic'
gem "auto_html", '= 1.4.2'
gem 'validation_reflection', :git => 'git://github.com/ncri/validation_reflection.git'
gem 'maxim-sexy_pg_constraints'
gem 'inherited_resources', '1.3.1'
gem 'spectator-validates_email', :require => 'validates_email'
gem 'has_vimeo_video', '>= 0.0.3'
gem 'wirble'
gem "on_the_spot"
gem 'weekdays'
gem 'brcep'
gem "RedCloth"
gem 'unicode'
gem 'routing-filter'
gem 'carrierwave', '= 0.5.8'
gem 'rmagick'
gem 'fog'
gem 'enumerate_it'
gem 'httparty', '~> 0.6.1'
gem "rack-timeout"
gem 'kaminari'
gem 'tumblr-api'
gem 'dalli'
gem 'mailee', '0.5.4', :git => 'https://github.com/danielweinmann/mailee-api.git'

# Translations
gem 'http_accept_language'
gem 'web_translate_it'

# Administration
gem 'activeadmin', :git => 'git://github.com/gregbell/active_admin.git'
gem "meta_search", "1.1.3"

# Payment
gem 'moip', :git => 'https://github.com/danielweinmann/moip-ruby.git', :ref => 'db1b879358c623b597dc1c221b53336f9f06db0e'
gem 'paypal-express', :require => 'paypal'

# Server
gem 'thin'
gem 'unicorn'

group :assets do
  gem 'sass'
  gem 'compass'
  gem 'sass-rails',   '~> 3.2.3'
  gem "compass-rails", "~> 1.0.1"
  gem 'uglifier', '>= 1.0.3'
  gem 'compass-960-plugin'
end

group :test, :development do
  gem 'annotate'
  gem 'launchy'
  gem 'database_cleaner'
  gem 'steak', "~> 1.1.0"
  gem 'rspec-rails', "~> 2.0.1"
  gem 'rcov', '= 0.9.11'
  gem 'mocha'
  gem 'capybara', ">= 1.0.1"
end

group :test do
  gem 'shoulda'
  gem 'factory_girl_rails', '1.7.0'
end