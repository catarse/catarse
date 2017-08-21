source 'https://rubygems.org'

ruby '2.4.1'

gem 'rails', '~> 4.2.8'

gem 'protected_attributes'
gem 'rails-observers'
gem 'rb-readline'

gem 'sidekiq',  '~> 4.0.1'

# Turns every field on a editable one
gem "best_in_place"

# State machine for attributes on models
# @TODO move payment to statesman
gem 'state_machines-activerecord'
gem 'statesman'

# Database and data related
gem 'pg', '0.19.0'
gem 'dbhero', '>= 1.1.12'
gem 'postgres-copy'
gem 'postgres_ext'
gem 'pg_search'
gem 'i18n_alchemy'
gem "i18n-js", ">= 3.0.0.rc11"
gem 'whenever'

gem 'schema_plus'
gem 'catarse_settings_db', '>= 0.2.0'

# Notifications
gem 'user_notifier', '~> 0.4.0'

# Mixpanel for backend tracking
gem 'mixpanel-ruby'
gem 'mixpanel_client'

# Payment engines

gem 'catarse_pagarme', '~> 2.10.13'
#gem 'catarse_pagarme', path: '../catarse_pagarme'

# Decorators
gem 'draper'
gem "sentry-raven"

# Frontend stuff
gem 'slim-rails'
gem 'browser', "1.0.1"
gem "cocoon"

# Static pages
gem 'high_voltage'

# Authentication and Authorization
gem 'simple_token_authentication', '~> 1.0' # see semver.org
gem 'omniauth'
gem 'omniauth-facebook'
gem 'koala'
gem 'devise', '3.5.10'
gem 'pundit'
gem 'json_web_token'

# Email marketing
gem 'gridhook'
gem 'sendgrid-ruby'

# HTML manipulation and formatting
gem 'simple_form'
gem 'mail_form'
gem "auto_html", "~> 1.6"
gem 'kaminari'
gem 'redactor-rails', github: 'catarse/redactor-rails', branch: 'master'

# Uploads
gem 'carrierwave', github: 'carrierwaveuploader/carrierwave', ref: '1578777fe3f30140347ebf27d1943471bbe4d425'
gem "mini_magick"

# Other Tools
gem 'to_xls'
gem 'ranked-model'
gem 'feedjira'
gem 'inherited_resources'
gem 'has_scope'
gem 'spectator-validates_email',  require: 'validates_email'
gem 'video_info'
gem 'typhoeus'
gem 'parallel'
gem 'sitemap_generator'
gem 'rdstation-ruby-client'
gem 'responders', '~> 2.0'
gem "cpf_cnpj"
gem 'aws-sdk', '~> 2'

# Translations
gem 'http_accept_language'
gem 'routing-filter', '~> 0.6.0'

group :production do
  # Gem used to handle image uploading
  gem 'fog-aws'

  # Workers, forks and all that jazz
  gem 'unicorn'

  # Enabling Gzip on Heroku
  # If you don't use Heroku, please comment the line below.
  gem 'heroku-deflater', '>= 0.4.1'

  # Make heroku serve static assets and loggin with stdout
  #gem 'rails_on_heroku'
  gem 'rails_12factor'

  # Monitoring with the new new relic
  gem 'newrelic_rpm', '~> 3.18.1.330'

  gem "activerecord-nulldb-adapter"

  # Using dalli and memcachier have not presented significative performance gains
  # Probably this is due to our pattern of cache usage
  # + the lack of concurrent procs in our deploy
  #gem 'memcachier'
  #gem 'dalli'
end
group :development do
  gem 'web-console'
  gem "rails-erd"
  gem "letter_opener"
  gem 'foreman'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'thin'
  # Uncomment only for optimization, should be commented on master branch
  # gem 'rack-mini-profiler'
  # gem 'ruby-prof'
end

group :test, :development do
  gem 'rspec-rails'
  gem 'rspec-mocks'
  gem 'rspec-its'
  gem 'rspec-collection_matchers'
  gem 'pry'
  gem 'jasmine-rails'
end

group :test do
  gem 'zonebie'
  gem 'fakeweb', github: 'SamMolokanov/fakeweb', branch: 'ruby-2-4-1-support'
  gem 'poltergeist'
  gem 'launchy'
  gem 'database_cleaner'
  gem 'shoulda'
  gem 'factory_girl_rails'
  gem 'capybara'
  gem 'selenium-webdriver'
end

gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'sass-rails'
gem 'coffee-rails'
gem 'compass-rails'
gem 'uglifier'
gem 'sprockets'
