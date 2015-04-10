RSpec.configure do |config|

  config.disable_monkey_patching!
  config.order = :random
  Kernel.srand config.seed
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end
  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
    mocks.verify_partial_doubles = true
  end
  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end

  config.before(:suite) do
    con = ActiveRecord::Base.connection
    con.execute "SET client_min_messages TO warning;"
    con.execute "SET timezone TO 'utc';"
    current_user = con.execute("SELECT current_user;")[0]["current_user"]
    con.execute %{ALTER USER #{current_user} SET search_path TO "$user", public, "1";}
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
    allow_any_instance_of(Project).to receive(:subscribe_to_list).and_return(true)
    allow_any_instance_of(ProjectObserver).to receive(:after_create)
    allow_any_instance_of(UserObserver).to receive(:after_create)
    allow_any_instance_of(Project).to receive(:download_video_thumbnail)
    allow_any_instance_of(Calendar).to receive(:fetch_events_from)
    allow(Blog).to receive(:fetch_last_posts).and_return([])

    # Default configurations
    CatarseSettings[:base_domain] = 'localhost'
    CatarseSettings[:host] = 'localhost'
    CatarseSettings[:email_contact] = 'foo@bar.com'
    CatarseSettings[:email_projects] = 'foo@bar.com'
    CatarseSettings[:email_system] = 'system@catarse.me'
    CatarseSettings[:company_name] = 'Foo Bar Company'

    # Email notification defaults
    UserNotifier.system_email     = CatarseSettings[:email_system]
    UserNotifier.from_email       = CatarseSettings[:email_contact]
    UserNotifier.from_name        = CatarseSettings[:company_name]

    allow_any_instance_of(Payment).to receive(:payment_engine).and_return(PaymentEngines::Interface.new)
    allow_any_instance_of(MixpanelObserver).to receive_messages(tracker: double('mixpanel tracker', track: nil, people: double('mixpanel people', {set: nil})))
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
