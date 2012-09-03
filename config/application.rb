require File.expand_path('../boot', __FILE__)
require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require *Rails.groups(:assets => %w(development test))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

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
    config.active_record.observers = [:backer_observer, :user_observer, :notification_observer, :update_observer]

    # Enable the asset pipeline
    config.assets.enabled = true
    config.assets.initialize_on_precompile = false

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'
  end
end
