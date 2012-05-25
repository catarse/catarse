if RUBY_VERSION =~ /1.9/
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end

source 'http://rubygems.org'
source 'http://gems.github.com'

# Paypal
gem 'activemerchant', '1.17.0', require: 'active_merchant'
gem 'active_paypal_adaptive_payment', '~> 0.3.13'
gem 'httpclient', '2.2.4'
gem 'selenium-webdriver', '2.21.1'


gem 'feedzirra'
gem 'rails', '3.0.3'
gem 'rake', '0.8.7'
gem 'haml'
gem 'slim'
gem 'slim-rails'
gem 'sass'
gem 'compass'
gem 'omniauth', '0.2.6'
gem 'formtastic', '2.0.2'
gem 'validation_reflection'
gem 'inherited_resources', '= 1.1.2'
gem 'maxim-sexy_pg_constraints'
gem 'spectator-validates_email', :require => 'validates_email'
gem 'has_vimeo_video', '>= 0.0.3'
gem 'wirble'
gem "on_the_spot"
gem 'unicorn'
gem 'mailee', '0.5.4', :git => 'https://github.com/danielweinmann/mailee-api.git'
# gem 'will_paginate', ">= 3.0.pre2"
gem 'weekdays'
gem 'moip', :git => 'https://github.com/danielweinmann/moip-ruby.git', :ref => 'db1b879358c623b597dc1c221b53336f9f06db0e'
gem 'paypal-express', :require => 'paypal'
gem 'brcep'
gem "meta_search", "1.0.6"
gem "RedCloth"
gem "auto_html", '= 1.3.6'
gem 'mustache'
gem 'unicode'
gem 'routing-filter'
gem 'http_accept_language'
gem 'cancan'
gem 'activeadmin', :git => 'git://github.com/gregbell/active_admin.git', :ref => '1f033aff5ed912faa5dfb6a0c013409e3e78b200'
gem 'carrierwave', '= 0.5.8'
gem 'rmagick'
gem 'fog'
gem 'capybara', ">= 1.0.1"
gem 'enumerate_it'
gem 'httparty', '~> 0.6.1'
gem "rack-timeout"
gem 'web_translate_it'

gem 'kaminari'
gem 'tumblr-api'
gem 'compass-960-plugin'
gem 'dalli'

gem "devise"

group :development, :production do
  gem 'thin'
end

group :test, :development do
  gem 'annotate'
  gem 'launchy'
  gem 'database_cleaner'
  gem 'steak', "~> 1.1.0"
  gem 'rspec-rails', "~> 2.0.1"
  gem 'rcov', '= 0.9.11'
  gem 'mocha'
end

group :test do
  gem 'shoulda'
  gem 'factory_girl_rails', '1.7.0'
end

# Putting pg to the end because of a weird bug with Lion, pg and openssl
gem 'pg'
gem 'foreigner'
