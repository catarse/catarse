source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.1'

gem 'rails', '4.2.11.3'
gem 'rails-html-sanitizer', '~> 1.0.4'

gem 'bigdecimal', '1.3.5'

gem 'countries', '3.0.0'
gem 'protected_attributes'
gem 'rails-observers'
gem 'rb-readline'
gem 'ruby-progressbar'

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
gem 'catarse_pagarme', '~> 2.16.2'
# gem 'catarse_pagarme', path: '../catarse_pagarme'

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
gem 'omniauth', '1.9.1'
gem 'omniauth-facebook'
gem 'koala'
gem 'devise', '4.7.2'
gem 'pundit'
gem 'json_web_token'

# Email marketing
gem 'gridhook'
gem 'sendgrid-ruby'
gem 'zendesk_api'

# HTML manipulation and formatting
gem 'simple_form'
gem 'mail_form'
gem "auto_html", "~> 1.6"
gem 'kaminari'
gem 'redactor-rails', github: 'catarse/redactor-rails', branch: 'master'

# Uploads
gem 'carrierwave', '~> 1.0'
gem 'mini_magick', '>= 4.9.4'

# Other Tools
gem 'excelinator'
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
  #gem 'thin'
  gem 'puma'
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

group :sandbox, :test, :development do
  gem 'faker'
  gem 'cpf_faker'
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
gem 'uglifier', '4.0.0'
gem 'sprockets', '~> 3.7.2'
gem "rack", ">= 1.6.11"
gem "loofah", ">= 2.2.3"
gem 'concurrent-ruby'
