ENV["RAILS_ENV"] ||= 'test'
require 'spec_helper'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'shoulda/matchers'
require 'sidekiq/testing'
require 'fakeweb'
require "pundit/rspec"

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

def fixture_path(basename)
  "spec/fixtures/#{basename}"
end

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  config.include ActionView::Helpers::TextHelper
  config.include FactoryGirl::Syntax::Methods
end

def create_contribution_with_payment project_id, payment_state
  c = create(:confirmed_contribution, value: 10.0, project_id: project_id)
  c.payments.first.update_attributes gateway_fee: 1, state: payment_state
  c
end

