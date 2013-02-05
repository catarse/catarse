source :gemcutter
source 'http://gems.github.com'

gem 'rails', '3.2.11'

gem 'sidekiq', '= 2.4.0'
gem 'sinatra', require: false
gem 'foreman'
gem 'best_in_place'

gem 'state_machine', require: 'state_machine/core'

# Database and data related
gem 'pg'
gem 'pg_search'
gem 'postgres-copy'
gem 'schema_plus'

gem 'catarse_paypal_express', git: 'git://github.com/devton/catarse_paypal_express.git', ref: '8f60d81b8f544003d99db4e80f945da6af1a9f4f'
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
gem 'omniauth', "~> 1.1.0"
gem 'omniauth-openid', '~> 1.0.1'
gem 'omniauth-twitter', '~> 0.0.12'
gem 'omniauth-facebook', '~> 1.2.0'
gem 'omniauth-github', '~> 1.0.1'
gem 'omniauth-linkedin', '~> 0.0.6'
gem 'omniauth-yahoo', '~> 0.0.4'
gem 'devise', '1.5.3'
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
gem 'memoist', '~> 0.2.0'
gem 'wirble'
gem "on_the_spot"
gem 'weekdays'
gem 'brcep'
gem "RedCloth"
gem 'unicode'
gem 'enumerate_it'
gem 'httparty', '~> 0.6.1'
gem "rack-timeout"

# Translations
gem 'http_accept_language'
gem 'routing-filter' #, :git => 'git://github.com/svenfuchs/routing-filter.git'

# Administration
gem "meta_search", "1.1.3"

# Payment
gem 'activemerchant', '1.17.0', require: 'active_merchant'
gem 'httpclient', '2.2.5'
gem 'selenium-webdriver'

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
  gem 'rspec-rails', "~> 2.10.0"
  gem 'mocha', '0.10.4'
  gem 'shoulda'
  gem 'factory_girl_rails', '1.7.0'
  gem 'capybara', ">= 1.0.1"
end

group :development do
  gem 'mailcatcher'
end
