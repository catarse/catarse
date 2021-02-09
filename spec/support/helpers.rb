# frozen_string_literal: true

Dir[Rails.root.join('spec/support/helpers/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.include ContributionSpecHelpers
  config.include ProjectSpecHelpers
end
