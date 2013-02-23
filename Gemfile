source :gemcutter

gem 'rails', '3.2.12'

gem 'sidekiq', '= 2.4.0'
gem 'sinatra', require: false
gem 'foreman'
gem 'best_in_place'

gem 'state_machine', require: 'state_machine/core'

# Database and data related
gem 'pg'
gem 'activerecord-postgresql-adapter'
gem 'pg_search'
gem 'postgres-copy'
gem 'schema_plus'
gem 'schema_associations'

gem 'catarse_stripe', git: 'git://github.com/lvxn0va/catarse_stripe.git', branch: 'master'
#gem 'catarse_stripe', path: '../catarse_stripe', branch: 'oauth'
gem 'stripe', :git => 'https://github.com/stripe/stripe-ruby'

gem 'catarse_paypal_express', git: 'git://github.com/devton/catarse_paypal_express.git', ref: '020e5851f8c2b08c9e4c1f4aab3627414644876b'
#gem 'catarse_paypal_express', path: '../catarse_paypal_express'

gem 'catarse_moip', git: 'git://github.com/devton/catarse_moip.git', ref: 'd71157a0365611048a36180846a3c0c84768b916'
#gem 'catarse_moip', path: '../catarse_moip'
gem 'moip', git: 'git://github.com/moiplabs/moip-ruby.git'



gem 'draper'

# Frontend stuff
gem 'slim'
gem 'slim-rails'
gem 'jquery-rails'
gem 'initjs'

# Authentication and Authorization
gem 'omniauth'
gem 'omniauth-openid'
gem 'omniauth-twitter'
gem 'omniauth-facebook'
gem 'omniauth-github'
gem 'omniauth-linkedin'
gem 'omniauth-yahoo'
gem 'omniauth-oauth2'
gem 'omniauth-stripe-connect'
gem 'oauth2'
gem 'devise'
gem 'cancan', git: 'git://github.com/ryanb/cancan.git', branch: '2.0', ref: 'f1cebde51a87be149b4970a3287826bb63c0ac0b'


# Error reporting
gem "airbrake"

# Email marketing
#gem 'mailchimp'
gem 'catarse_mailchimp', git: 'git://github.com/devton/catarse_mailchimp'

# HTML manipulation and formatting
gem 'formtastic', "~> 2.1.1"
gem "auto_html", '= 1.4.2'
gem 'kaminari'
gem 'rails_autolink', '~> 1.0.7'

# Uploads
gem 'carrierwave', '~> 0.7.0'
gem 'rmagick'
gem 'fog'

# Other Tools
gem 'feedzirra'
gem 'validation_reflection', git: 'git://github.com/ncri/validation_reflection.git'
gem 'inherited_resources', '1.3.1'
gem 'has_scope'
gem 'spectator-validates_email', require: 'validates_email'
gem 'has_vimeo_video', '~> 0.0.5'
gem 'weekdays'
gem "RedCloth"
gem 'enumerate_it'
gem 'httparty', '~> 0.6.1'
gem "rack-timeout"
gem 'figaro'
gem 'json'

# Translations
gem 'http_accept_language'
gem 'routing-filter' #, :git => 'git://github.com/svenfuchs/routing-filter.git'

# Payment
gem 'activemerchant', '1.17.0'
gem 'httpclient', '2.2.5'

# Server
gem 'thin'

group :assets do
  gem 'sass-rails',   '~> 3.2.5'
  gem 'coffee-rails', '~> 3.2.2'
  gem "compass-rails", "~> 1.0.2"
  gem 'uglifier', '>= 1.0.3'
  gem 'compass-960-plugin', '~> 0.10.4'
end

group :test, :development do
  gem 'launchy'
  gem 'database_cleaner'
  gem 'rspec-rails', "~> 2.12"
  gem 'mocha', '0.10.4'
  gem 'shoulda'
  gem 'factory_girl_rails'
  gem 'capybara', ">= 1.0.1"
end

group :development do
  gem 'mailcatcher'
  gem "better_errors"
  gem "binding_of_caller"
end
