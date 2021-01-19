# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'

require File.expand_path("../dummy/config/environment", __FILE__)

require 'database_cleaner'
require 'pagarme'
require 'open-uri'
require 'rspec/rails'
require 'factory_girl'
require 'sidekiq/testing'
# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[ File.expand_path("../support/**/*.rb", __FILE__)].each {|f| require f}

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.use_transactional_examples = false

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:suite) do
    DatabaseCleaner.clean_with :truncation
    DatabaseCleaner.strategy = :transaction

    con = ActiveRecord::Base.connection
    con.execute %{
    INSERT INTO public.project_states (state, state_order) VALUES
    ('deleted', 'archived'),
    ('rejected', 'created'),
    ('draft', 'created'),
    ('in_analysis', 'created'),
    ('approved', 'publishable'),
    ('online', 'published'),
    ('waiting_funds', 'published'),
    ('failed', 'finished'),
    ('successful', 'finished');

    INSERT INTO public.flexible_project_states (state, state_order) VALUES
    ('deleted', 'archived'),
    ('rejected', 'created'),
    ('draft', 'created'),
    ('in_analysis', 'created'),
    ('approved', 'publishable'),
    ('online', 'published'),
    ('waiting_funds', 'published'),
    ('failed', 'finished'),
    ('successful', 'finished');
    }
  end

  config.before(:each) do
    DatabaseCleaner.start
    ActionMailer::Base.deliveries.clear
    allow(PagarMe).to receive(:api_key).and_return(ENV['TEST_GATEWAY_API_KEY'])
    allow(PaymentEngines).to receive(:configuration).and_return({})
    Sidekiq::Testing.inline!
    allow(CatarsePagarme::VerifyPagarmeWorker).to receive(:perform_in).and_return(true)
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end

def sample_card_hash
  r = open("https://api.pagar.me/1/transactions/card_hash_key/?encryption_key=ek_test_zwAwnRvqD1c9GUERQ7oAP4FPyN9o2v").read
  json = ActiveSupport::JSON.decode(r)
  public_key = OpenSSL::PKey::RSA.new(json["public_key"])
  encode_string = Base64.encode64(public_key.public_encrypt("card_number=4901720080344448&card_holder_name=Usuario de Teste&card_expiration_date=1220&card_cvv=314"))

  "#{json['id']}_#{encode_string}"
end
