require File.expand_path('../boot', __FILE__)
require 'rails/all'
Bundler.require(:default, Rails.env) if defined?(Bundler)
module Catarse
  class Application < Rails::Application
    config.active_record.schema_format = :sql
    config.autoload_paths += %W(#{config.root}/lib #{config.root}/lib/** #{config.root}/app/presenters #{config.root}/app/presenters/** #{config.root}/app/business/ #{config.root}/app/business/**)
    config.encoding = "utf-8"
    config.filter_parameters += [:password, :password_confirmation]
    config.time_zone = 'Brasilia'
    config.generators do |g|
      g.template_engine :haml
      g.test_framework :rspec, :fixture => false, :views => false
    end
    ActiveRecord::Base.include_root_in_json = false
  end
end
