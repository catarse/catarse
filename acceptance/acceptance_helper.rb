# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'factory_girl_rails'
require 'rspec/rails'
require 'capybara/rspec'
require 'capybara/rails'


# Put your acceptance spec helpers inside /spec/acceptance/support
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

module Capybara
 module DSL
   # Ignoring scopes inside a block
   #
   # ==== Examples
   #
   #     within '.records' do
   #       within '.record' do
   #         ignoring_scopes do
   #           click_link 'Link outside .records .record'
   #         end
   #       end
   #     end
   #
   def ignoring_scopes
     original_scopes = page.send(:scopes).slice!(1..-1)
     yield
   ensure
     page.send(:scopes).push(*original_scopes)
   end
 end
end

module Capybara
 module Node
   class Base
     def click_link(locator, options = {})
       confirm = options.delete(:confirm)

       if confirm
         driver.execute_script 'this._confirm = this.confirm'
         driver.execute_script 'this.confirm = function () { return true }'
       end

       super(locator)

       if confirm
         driver.execute_script 'this.confirm = this._confirm'
       end
     end
   end
 end
end

Capybara.app = ::Rails.application

Capybara.register_driver :rack_test do |app|
  Capybara::RackTest::Driver.new(app, :browser => :chrome)
end

Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, :browser => :chrome)
end

Capybara.configure do |config|
 config.default_driver = defined?(Capybara::Driver::Webkit) ? :webkit : :selenium
 config.ignore_hidden_elements = false
 # config.seletor :css
 config.server_port = 8200
 config.app_host = "http://localhost:8200"
end

class ActionDispatch::IntegrationTest
 include Capybara::DSL

 teardown do
   Capybara.reset_sessions!
 end
end

RSpec.configure do |config|
  config.include Capybara::DSL
  config.include NavigationHelpers
  config.include HelperMethods
  config.include Rack::Test::Methods
  config.include Factory::Syntax::Methods

  config.mock_with :mocha

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  config.before(:suite) do
    ActiveRecord::Base.connection.execute "SET client_min_messages TO warning;"
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.clean
  end
end

include Rails.application.routes.url_helpers

I18n.locale = :pt
I18n.default_locale = :pt