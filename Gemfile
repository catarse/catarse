source 'http://rubygems.org'
source 'http://gems.github.com'

gem 'rails', '3.2.6'
gem 'rake', '0.9.2.2'

# Database [Putting pg to the end because of a weird bug with Lion, pg and openssl]
gem 'pg'
gem 'foreigner'
gem 'activerecord-postgresql-adapter'

# Frontend stuff
gem 'jquery-rails'
gem 'slim'
gem 'slim-rails'

# Authentication and Authorization
gem 'omniauth', "~> 1.1.0"
gem 'omniauth-openid', '~> 1.0.1'
gem 'omniauth-twitter', '~> 0.0.12'
gem 'omniauth-facebook', '~> 1.2.0'
gem 'omniauth-github', '~> 1.0.1'
gem 'omniauth-linkedin', '~> 0.0.6'
gem 'omniauth-yahoo', '~> 0.0.4'
gem 'devise', '1.5.3'
gem 'cancan'

gem 'rails_autolink', '~> 1.0.7'

# Tools
gem "airbrake"
gem 'feedzirra'
gem 'formtastic'
gem "auto_html", '= 1.4.2'
gem 'validation_reflection', git: 'git://github.com/ncri/validation_reflection.git'
gem 'maxim-sexy_pg_constraints'
gem 'inherited_resources', '1.3.1'
gem 'spectator-validates_email', require: 'validates_email'
gem 'has_vimeo_video', '>= 0.0.4'
gem 'wirble'
gem "on_the_spot"
gem 'weekdays'
gem 'brcep'
gem "RedCloth"
gem 'unicode'
gem 'carrierwave', '= 0.5.8'
gem 'rmagick'
gem 'fog'
gem 'enumerate_it'
gem 'httparty', '~> 0.6.1'
gem "rack-timeout"
gem 'kaminari'
gem 'tumblr-api'
gem 'dalli'
gem 'mailee', '0.5.4', git: 'https://github.com/danielweinmann/mailee-api.git'
gem 'capybara', ">= 1.0.1"

# Translations
gem 'http_accept_language'
gem 'web_translate_it'
gem 'routing-filter' #, :git => 'git://github.com/svenfuchs/routing-filter.git'

# Administration
gem 'activeadmin', git: 'git://github.com/gregbell/active_admin.git'
gem "meta_search", "1.1.3"

# Payment (moip)
gem 'moip', git: 'https://github.com/danielweinmann/moip-ruby.git', ref: 'db1b879358c623b597dc1c221b53336f9f06db0e'

# Payment (paypal adaptive)
gem 'activemerchant', '1.17.0', require: 'active_merchant'
#gem 'active_paypal_adaptive_payment', '~> 0.3.13'
gem 'httpclient', '2.2.5'
gem 'selenium-webdriver', '2.21.2'
gem 'bourbon'
gem 'paypal-express', :require => 'paypal'

# Server
gem 'thin'

group :assets do
  gem 'sass-rails',   '~> 3.2.5'
  gem 'coffee-rails', '~> 3.2.2'
  gem "compass-rails", "~> 1.0.1"
  gem 'uglifier', '>= 1.0.3'
  gem 'compass-960-plugin', '~> 0.10.4'
end

group :test, :development do
  gem 'annotate'
  gem 'launchy'
  gem 'database_cleaner'
  gem 'steak', "~> 1.1.0"
  gem 'rspec-rails', "~> 2.10.0"
  gem 'rcov', '= 0.9.11'
  gem 'mocha', '0.10.4'
end

group :development do
  gem 'mailcatcher'
  gem 'ruby-debug19'
end

group :test do
  gem 'shoulda'
  gem 'factory_girl_rails', '1.7.0'
end
