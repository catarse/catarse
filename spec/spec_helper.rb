# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require 'coveralls'
Coveralls.wear!('rails')

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'sidekiq/testing'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.include ActionView::Helpers::TextHelper

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  #config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  config.before(:suite) do
    ActiveRecord::Base.connection.execute "SET client_min_messages TO warning;"
    DatabaseCleaner.clean_with :truncation
    I18n.locale = :pt
    I18n.default_locale = :pt
  end

  config.before(:each) do
    if example.metadata[:type] == :feature
      DatabaseCleaner.strategy = :truncation
    else
      DatabaseCleaner.strategy = :transaction
    end
    DatabaseCleaner.start
    ActionMailer::Base.deliveries.clear
    RoutingFilter.active = false # Because this issue: https://github.com/svenfuchs/routing-filter/issues/36
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.before(:each, type: :controller) do
    [Projects::BackersController, Users::BackersController, UsersController, UnsubscribesController, ProjectsController, ExploreController].each do |c|
      c.any_instance.stub(:render_facebook_sdk)
      c.any_instance.stub(:render_facebook_like)
      c.any_instance.stub(:render_twitter)
      c.any_instance.stub(:display_uservoice_sso)
    end
  end

  # Stubs and configuration
  config.before(:each) do
    CatarseMailchimp::API.stub(:subscribe).and_return(true)
    CatarseMailchimp::API.stub(:unsubscribe).and_return(true)
    PaperTrail.controller_info = {}
    PaperTrail.whodunnit = nil
    Project.any_instance.stub(:store_image_url).and_return('http://www.store_image_url.com')
    ProjectObserver.any_instance.stub(:after_create)
    UserObserver.any_instance.stub(:after_create)
    Project.any_instance.stub(:download_video_thumbnail)
    CatarseMailchimp::API.stub(:subscribe)
    CatarseMailchimp::API.stub(:unsubscribe)
    Notification.stub(:create_notification)
    Notification.stub(:create_notification_once)
    Calendar.any_instance.stub(:fetch_events_from)
    Blog.stub(:fetch_last_posts).and_return([])
    ::Configuration[:base_domain] = 'localhost'
    ::Configuration['email_contact'] = 'foo@bar.com'
  end
end

