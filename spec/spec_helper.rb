# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require 'coveralls'
Coveralls.wear!('rails')

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'sidekiq/testing'
require 'fakeweb'
require "pundit/rspec"

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

def fixture_path(basename)
  "spec/fixtures/#{basename}"
end


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

  config.infer_spec_type_from_file_location!

  config.before(:suite) do
    ActiveRecord::Base.connection.execute "SET client_min_messages TO warning;"
    ActiveRecord::Base.connection.execute "SET timezone TO 'utc';"
    DatabaseCleaner.clean_with :truncation
    I18n.locale = :pt
    I18n.default_locale = :pt

    FakeWeb.register_uri(:get, "http://vimeo.com/api/v2/video/17298435.json", response: fixture_path('vimeo_default_json_request.txt'))
    FakeWeb.register_uri(:get, "http://vimeo.com/17298435", response: fixture_path('vimeo_default_request.txt'))
    FakeWeb.register_uri(:get, "http://www.youtube.com/watch?v=Brw7bzU_t4c", response: fixture_path("youtube_request.txt"))
  end

  config.before(:each) do
    if RSpec.current_example.metadata[:type] == :feature
      DatabaseCleaner.strategy = :truncation
    else
      DatabaseCleaner.strategy = :transaction
    end
    DatabaseCleaner.start
    ActionMailer::Base.deliveries.clear
    RoutingFilter.active = false # Because this issue: https://github.com/svenfuchs/routing-filter/issues/36
    Sidekiq::Testing.fake!
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  [:controller, :feature].each do |spec_type|
    config.before(:each, type: spec_type) do
      [:detect_old_browsers, :render_facebook_sdk, :render_facebook_like, :render_twitter].each do |method|
        allow_any_instance_of(ApplicationController).to receive(method)
      end
    end
  end

  # Stubs and configuration
  config.before(:each) do
    allow(Sidekiq::ScheduledSet).to receive(:new).and_return({})
    allow_any_instance_of(User).to receive(:subscribe_to_newsletter_list).and_return(true)
    allow_any_instance_of(User).to receive(:unsubscribe_to_newsletter_list).and_return(true)
    allow_any_instance_of(Project).to receive(:subscribe_to_list).and_return(true)
    allow_any_instance_of(Project).to receive(:store_image_url).and_return('http://www.store_image_url.com')
    allow_any_instance_of(ProjectObserver).to receive(:after_create)
    allow_any_instance_of(UserObserver).to receive(:after_create)
    allow_any_instance_of(Project).to receive(:download_video_thumbnail)
    allow_any_instance_of(Calendar).to receive(:fetch_events_from)
    allow(Blog).to receive(:fetch_last_posts).and_return([])

    # Default configurations
    CatarseSettings[:base_domain] = 'localhost'
    CatarseSettings[:email_contact] = 'foo@bar.com'
    CatarseSettings[:email_projects] = 'foo@bar.com'
    CatarseSettings[:email_system] = 'system@catarse.me'
    CatarseSettings[:company_name] = 'Foo Bar Company'

    # Email notification defaults
    UserNotifier.system_email     = CatarseSettings[:email_system]
    UserNotifier.from_email       = CatarseSettings[:email_contact]
    UserNotifier.from_name        = CatarseSettings[:company_name]

    allow_any_instance_of(Contribution).to receive(:payment_engine).and_return(PaymentEngines::Interface.new)
    allow_any_instance_of(MixpanelObserver).to receive_messages(tracker: double('mixpanel tracker', track: nil))
  end
end

RSpec::Matchers.define :custom_permit do |action|
  match do |policy|
    policy.public_send("#{action}")
  end

  failure_message do |policy|
    "#{policy.class} does not permit #{action} on #{policy.record} for #{policy.user.inspect}."
  end

  failure_message_when_negated do |policy|
    "#{policy.class} does not forbid #{action} on #{policy.record} for #{policy.user.inspect}."
  end
end
