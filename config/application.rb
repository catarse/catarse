require File.expand_path('../boot', __FILE__)
require 'rails/all'
Bundler.require(:default, Rails.env) if defined?(Bundler)
module Catarse
  class Application < Rails::Application
    config.i18n.default_locale = :en
    config.active_record.schema_format = :sql
    config.encoding = "utf-8"
    config.filter_parameters += [:password, :password_confirmation]
    config.generators do |g|
      g.template_engine :haml
      g.test_framework :rspec, :fixture => false, :views => false
    end
  end
end
