source 'https://rubygems.org'

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.2'

gem 'auto_html', '2.0.0'
gem 'bootsnap', '1.5.1', require: false
gem 'browser', '5.1.0'
gem 'carrierwave', '2.1.0'
gem 'catarse_pagarme', github: 'catarse/catarse_pagarme', branch: 'qa/rails_6'
gem 'catarse_scripts', path: 'engines/catarse_scripts'
gem 'catarse_settings_db', '0.2.0'
gem 'concurrent-ruby', '1.1.7'
gem 'countries', '3.0.1'
gem 'cpf_cnpj', '0.5.0'
gem 'dbhero', '1.1.12'
gem 'devise', '4.7.3'
gem 'draper', '4.0.1'
gem 'excelinator', '1.3.1'
gem 'feedjira', '3.1.2'
gem 'gridhook', '0.2.0'
gem 'has_scope', '0.7.2'
gem 'high_voltage', '3.1.2'
gem 'i18n_alchemy', '0.3.1', github: 'stephannv/i18n_alchemy', branch: 'master'
gem 'i18n-js', '3.8.0'
gem 'inherited_resources', '1.12.0'
gem 'jquery-rails', '4.4.0'
gem 'jquery-ui-rails', '6.0.1'
gem 'jwt', '2.2.2'
gem 'kaminari', '1.2.1'
gem 'koala', '3.0.0'
gem 'mini_magick', '4.11.0'
gem 'omniauth', '1.9.1'
gem 'omniauth-facebook', '8.0.0'
gem 'parallel', '1.20.1'
gem 'pg', '1.2.3'
gem 'pg_search', '2.3.5'
gem 'postgres-copy', '1.5.0'
gem 'puma', '5.1.1'
gem 'pundit', '2.1.0'
gem 'rack-cors', '1.1.1'
gem 'rails', '6.1.0'
gem 'rails-html-sanitizer', '1.3.0'
gem 'rails-observers', '0.1.5'
gem 'ranked-model', '0.4.6'
gem 'rdstation-ruby-client', '0.0.5'
gem 'redactor-rails', '0.7.0', github: 'catarse/redactor-rails', branch: 'master'
gem 'redis', '4.2.5'
gem 'responders', '3.0.1'
gem 'sass-rails', '6.0.0'
gem 'sendgrid-ruby', '4.0.6'
gem 'sentry-raven', '3.1.1'
gem 'sidekiq',  '6.1.2'
gem 'sidekiq-status', '1.1.4'
gem 'simple_form', '5.0.3'
gem 'simple_token_authentication', '1.17.0'
gem 'sitemap_generator', '6.1.2'
gem 'slim-rails', '3.2.0'
gem 'sprockets', '3.7.2'
gem 'statesman', '7.4.1'
gem 'state_machines-activerecord', '0.6.0'
gem 'typhoeus', '1.4.0'
gem 'tzinfo-data', '1.2.7', platforms: %i[mingw mswin x64_mingw jruby]
gem 'user_notifier', '0.4.0', github: 'stephannv/user_notifier', branch: 'master'
gem 'video_info', '3.0.0'
# REQUIRE DISABLED TO NOT HOOK UP webpacker:compile INTO assets:precompile
# https://github.com/rails/webpacker/blob/master/docs/deployment.md
gem 'webpacker', '5.2.1', require: false
gem 'whenever', '1.0.0'
gem 'zendesk_api', '1.28.0'

group :production do
  gem 'fog-aws', '3.7.0'
end

group :development do
  gem 'letter_opener', '1.7.0'
  gem 'listen', '3.3.3'
  gem 'rack-mini-profiler', '~> 2.0'
  gem 'spring', '2.1.1'
  gem 'web-console', '4.1.0'
end

group :development, :test do
  gem 'awesome_print', '1.8.0'
  gem 'byebug', '11.1.3', platform: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails', '6.1.0'
  gem 'faker', '2.15.1'
  gem 'rspec-rails', '4.0.1'
  gem 'rubocop', '1.6.1'
  gem 'rubocop-performance', '1.9.1'
  gem 'rubocop-rails', '2.9.0'
  gem 'rubocop-rspec', '2.0.1'
end

group :test do
  gem 'rails-controller-testing', '1.0.5'
  gem 'shoulda-matchers', '4.4.1'
  gem 'webmock', '3.10.0'
end
