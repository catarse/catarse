source 'https://rubygems.org'

ruby '2.1.2'

gem 'rails',    '~> 4.1.1'

gem 'protected_attributes', '~> 1.0.5' # When upgrade to strong_parameters, remove this gem.
gem 'rails-observers', '~> 0.1.2'

gem 'sidekiq',  '~> 3.1.3'
gem 'sinatra', require: false # required by sidekiq web interface mounted on /sidekiq

# Turns every field on a editable one
gem 'best_in_place', github: 'bernat/best_in_place', branch: 'rails-4'

# State machine for attributes on models
gem 'state_machine', require: 'state_machine/core'

# Database and data related
gem 'pg'
gem 'postgres-copy'
gem 'pg_search'

gem 'schema_plus'
gem 'schema_associations'
gem 'chartkick'
gem 'catarse_settings_db'

# Mixpanel for backend tracking
gem 'mixpanel-ruby'

# Payment engines
gem 'catarse_paypal_express', '2.2.3'
gem 'catarse_moip', '~> 2.3.5'
# gem 'catarse_wepay', '~> 0.0.1'

# Decorators
gem 'draper'

# Frontend stuff
gem 'slim-rails'
gem 'jquery-rails'
gem 'browser'

# Static pages
gem 'high_voltage'

# Authentication and Authorization
gem 'omniauth'
gem 'omniauth-twitter'
gem 'omniauth-facebook', '1.4.0'
gem 'devise'
gem 'ezcrypto'
gem 'pundit'

# Email marketing
gem 'catarse_monkeymail', '>= 0.1.6'

# HTML manipulation and formatting
gem 'formtastic',   '~> 2.2.1'
gem 'simple_form'
gem "auto_html",    '= 1.4.2'
gem "RedCloth"
gem 'kaminari'

# Uploads
gem 'carrierwave', '~> 0.10.0'
gem 'rmagick', :require => 'RMagick'

# Other Tools
gem 'to_xls'
gem 'ranked-model'
gem 'feedjira'
gem 'inherited_resources',        '~> 1.4.1'
gem 'has_scope', '~> 0.6.0.rc'
gem 'spectator-validates_email',  require: 'validates_email'
gem 'video_info', '>= 1.1.1'
gem 'httparty', '~> 0.6.1' # this version is required by moip gem, otherwise payment confirmation will break

# Translations
gem 'http_accept_language'
gem 'routing-filter', '~> 0.4.0.pre'

# Payment
gem 'moip', github: 'catarse/moip-ruby', ref: 'c0225ad71645cd1df35dafa1e45c9f092b3abb9e'
gem 'httpclient',     '>= 2.2.5'

group :production do
  # Gem used to handle image uploading
  gem 'fog', '>= 1.3.1'

  # Workers, forks and all that jazz
  gem 'unicorn'

  # Enabling Gzip on Heroku
  # If you don't use Heroku, please comment the line below.
  gem 'heroku-deflater', '>= 0.4.1'

  # Make heroku serve static assets and loggin with stdout
  #gem 'rails_on_heroku'
  gem 'rails_12factor'

  # Monitoring with the new new relic
  gem 'newrelic_rpm', '3.6.5.130'

  # Using dalli and memcachier have not presented significative performance gains
  # Probably this is due to our pattern of cache usage
  # + the lack of concurrent procs in our deploy
  #gem 'memcachier'
  #gem 'dalli'
end
group :development do
  gem "letter_opener"
  gem 'foreman'
  gem 'better_errors'
  gem 'binding_of_caller'
  # Uncomment only for optimization, should be commented on master branch
  # gem 'rack-mini-profiler'
end

group :test, :development do
  gem 'rspec-rails', '~> 2.14.0'
  gem 'pry'
  gem 'jasmine-rails'
end

group :test do
  gem 'fakeweb'
  gem 'poltergeist'
  gem 'launchy'
  gem 'database_cleaner'
  gem 'shoulda'
  gem 'factory_girl_rails'
  gem 'capybara',   '~> 2.1.0'
  gem 'coveralls', require: false
  gem 'selenium-webdriver'
end

gem 'sass-rails', '~> 4.0.0'
gem 'coffee-rails', '~> 4.0.0'
gem "compass-rails"
gem 'uglifier'
gem 'compass-960-plugin'
gem 'sprockets', '~> 2.10.1'

# FIXME: Not-anymore-on-development
# Gems that are with 1 or more years on the vacuum
gem 'weekdays'
