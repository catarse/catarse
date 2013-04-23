# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require 'coveralls'
Coveralls.wear!('rails')

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'sidekiq/testing'


# Preparing devise to be tested again Capybara acceptance tests
include Warden::Test::Helpers
Warden.test_mode!


# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :mocha
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
    DatabaseCleaner.strategy = :truncation
  end

  config.after(:each) do
    Warden.test_reset! 
    DatabaseCleaner.clean
    
  end

  config.before(:each) do
    CatarseMailchimp::API.stubs(:subscribe).returns(true)
    CatarseMailchimp::API.stubs(:unsubscribe).returns(true)    
    PaperTrail.controller_info = {}
    PaperTrail.whodunnit = nil
    DatabaseCleaner.start
    ActionMailer::Base.deliveries.clear
    Project.any_instance.stubs(:store_image_url).returns('http://www.store_image_url.com')
    Project.any_instance.stubs(:download_video_thumbnail)
    CatarseMailchimp::API.stubs(:subscribe)
    CatarseMailchimp::API.stubs(:unsubscribe)
    Notification.stubs(:create_notification)
    Notification.stubs(:create_notification_once)
    ProjectObserver.any_instance.stubs(:after_create)
    Calendar.any_instance.stubs(:fetch_events_from)
    Blog.stubs(:fetch_last_posts).returns([])
    [Projects::BackersController, ::BackersController, UsersController, UnsubscribesController, ProjectsController, ExploreController].each do |c|
      c.any_instance.stubs(:render_facebook_sdk)
      c.any_instance.stubs(:render_facebook_like)
      c.any_instance.stubs(:render_twitter)
    end
    DatabaseCleaner.clean
    RoutingFilter.active = false # Because this issue: https://github.com/svenfuchs/routing-filter/issues/36
    Configuration[:base_domain] = 'localhost'
  end

  def mock_tumblr method=:two
    require "#{Rails.root}/spec/fixtures/tumblr_data" # just a fixture
    Tumblr::Post.stubs(:all).returns(TumblrData.send(method))
  end
end



I18n.locale = :pt
I18n.default_locale = :pt

