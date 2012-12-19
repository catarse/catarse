# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'sidekiq/testing'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :mocha
  config.include Factory::Syntax::Methods
  config.include ActionView::Helpers::TextHelper

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  config.before(:suite) do
    ActiveRecord::Base.connection.execute "SET client_min_messages TO warning;"
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with :truncation
  end

  config.before type: :request do
    DatabaseCleaner.strategy = :truncation
  end

  config.after type: :request do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each) do
    DatabaseCleaner.start
    ActionMailer::Base.deliveries.clear
    Project.any_instance.stubs(:store_image_url).returns('http://www.store_image_url.com')
    Project.any_instance.stubs(:download_video_thumbnail)
    CatarseMailchimp::API.stubs(:subscribe)
    CatarseMailchimp::API.stubs(:unsubscribe)
    Notification.stubs(:create_notification)
    Notification.stubs(:create_notification_once)
  end

  config.after do
    DatabaseCleaner.clean
  end

  def mock_tumblr method=:two
    require "#{Rails.root}/spec/fixtures/tumblr_data" # just a fixture
    Tumblr::Post.stubs(:all).returns(TumblrData.send(method))
  end
end

RoutingFilter.active = false # Because this issue: https://github.com/svenfuchs/routing-filter/issues/36


I18n.locale = :pt
I18n.default_locale = :pt

