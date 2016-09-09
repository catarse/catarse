require File.expand_path('../boot', __FILE__)
require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require *Rails.groups(assets: %w(development test))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Catarse
  class Application < Rails::Application
    config.to_prepare do
      Devise::Mailer.layout "email" # email.haml or email.erb
    end

    config.paths['app/views'].unshift("#{Rails.root}/app/views/catarse_bootstrap")

    #NOTE: the custom view path is for build a new style without need to
    # edit the catarse_views
    #raise config.paths['app/views'].inspect
    config.paths['app/views'].unshift("#{Rails.root}/app/views/custom")

    config.active_record.schema_format = :sql

    # Since Rails 3.1, all folders inside app/ will be loaded automatically
    config.autoload_paths += %W(#{config.root}/lib #{config.root}/lib/**)

    # Default encoding for the server
    config.encoding = "utf-8"

    config.filter_parameters += [:password, :password_confirmation]
    config.time_zone = 'Brasilia'
    config.active_record.default_timezone = :utc
    config.generators do |g|
      g.test_framework :rspec, fixture: false, views: false
    end
    config.active_record.observers = [
      :contribution_observer, :payment_observer, :user_observer, :project_post_observer, :project_observer,
      :flexible_project_observer, :mixpanel_observer, '::CatarseMonkeymail::MonkeyProjectObserver',
    ]

    # Enable the asset pipeline
    config.assets.enabled = true

    # Don't initialize the app when compiling
    config.assets.initialize_on_precompile = false

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    config.active_record.dump_schema_after_migration = false

    # TODO: remove
    config.active_record.whitelist_attributes = false

  end
end
