Dir[Rails.root.join('spec/support/helpers/*.rb')].sort.each { |f| require f }

RSpec.configure do |config|
  config.include ContributionSpecHelpers
  config.include ProjectSpecHelpers
end
