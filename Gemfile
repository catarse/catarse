# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.2'

gem 'auto_html', '2.0.0'
gem 'bootsnap', '1.9.1', require: false
gem 'browser', '5.3.1'
gem 'carrierwave', '2.2.2'
gem 'catarse_pagarme', path: 'engines/catarse_pagarme'
gem 'catarse_scripts', path: 'engines/catarse_scripts'
gem 'catarse_settings_db', '0.2.0'
gem 'concurrent-ruby', '1.1.9'
gem 'countries', '4.0.1'
gem 'cpf_cnpj', '0.5.0'
gem 'dbhero', github: 'catarse/dbhero', branch: 'master'
gem 'devise', '4.8.0'
gem 'draper', '4.0.2'
gem 'excelinator', github: 'stephannv/excelinator', branch: 'master'
gem 'feedjira', '3.2.0'
gem 'gridhook', github: 'catarse/gridhook', branch: 'master'
gem 'has_scope', '0.8.0'
gem 'high_voltage', '3.1.2'
gem 'i18n_alchemy', '0.3.1', github: 'stephannv/i18n_alchemy', branch: 'master'
gem 'i18n-js', '3.9.0'
gem 'inherited_resources', '1.13.0'
gem 'jquery-rails', '4.4.0'
gem 'jquery-ui-rails', '6.0.1'
gem 'jwt', '2.3.0'
gem 'kaminari', '1.2.1'
gem 'koala', '3.0.0'
gem 'mini_magick', '4.11.0'
gem 'money-rails', '1.15.0'
gem 'omniauth', '2.0.4'
gem 'omniauth-facebook', '9.0.0'
gem 'omniauth-google-oauth2', '1.0.0'
gem 'omniauth-rails_csrf_protection', '1.0.0'
gem 'parallel', '1.21.0'
gem 'pg', '1.2.3'
gem 'pg_search', '2.3.5'
gem 'postgres-copy', '1.5.0'
gem 'puma', '5.5.2'
gem 'pundit', '2.1.1'
gem 'rack-cors', '1.1.1'
gem 'rails', '6.1.4.4'
gem 'rails-html-sanitizer', '1.4.2'
gem 'rails-observers', '0.1.5'
gem 'ranked-model', '0.4.7'
gem 'rdstation-ruby-client', '0.0.5'
gem 'redactor-rails', '0.7.0', github: 'catarse/redactor-rails', branch: 'master'
gem 'redis', '4.5.1'
gem 'responders', '3.0.1'
gem 'rqrcode', '2.1.0'
gem 'sass-rails', '6.0.0'
gem 'sendgrid-ruby', '4.0.6'
gem 'sentry-rails', '4.7.3'
gem 'sentry-ruby', '4.7.3'
gem 'sidekiq', '6.4.0'
gem 'sidekiq-status', '2.1.0'
gem 'simple_form', '5.1.0'
gem 'simple_token_authentication', '1.17.0'
gem 'sitemap_generator', '6.1.2'
gem 'slim-rails', '3.3.0'
gem 'sprockets', '3.7.2'
gem 'state_machines-activerecord', '0.8.0'
gem 'statesman', '9.0.0'
gem 'typhoeus', '1.4.0'
gem 'tzinfo-data', '1.2.7', platforms: %i[mingw mswin x64_mingw jruby]
gem 'user_notifier', '0.4.0', github: 'stephannv/user_notifier', branch: 'master'
gem 'video_info', '3.0.1'
# REQUIRE DISABLED TO NOT HOOK UP webpacker:compile INTO assets:precompile
# https://github.com/rails/webpacker/blob/master/docs/deployment.md
gem 'webpacker', '5.4.3', require: false
gem 'whenever', '1.0.0'
gem 'zendesk_api', '1.33.0'

group :production do
  gem 'fog-aws', '3.12.0'
end

group :development do
  gem 'brakeman', '5.1.2'
  gem 'letter_opener', '1.7.0'
  gem 'listen', '3.7.0'
  gem 'rack-mini-profiler', '2.3.3'
  gem 'spring', '3.0.0'
  gem 'web-console', '4.1.0'
end

group :development, :test do
  gem 'awesome_print', '1.9.2'
  gem 'byebug', '11.1.3', platform: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails', '6.2.0'
  gem 'faker', '2.19.0'
  gem 'rspec-rails', '5.0.2'
end

group :test do
  gem 'rails-controller-testing', '1.0.5'
  gem 'shoulda-matchers', '5.0.0'
  gem 'webmock', '3.14.0'
end

group :code_analysis do
  gem 'rubocop', '1.22.3'
  gem 'rubocop-performance', '1.12.0'
  gem 'rubocop-rails', '2.12.4'
  gem 'rubocop-rspec', '2.6.0'
end
