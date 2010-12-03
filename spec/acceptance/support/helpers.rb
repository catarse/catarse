module HelperMethods
  # Put helper methods you need to be available in all tests here.
  def login
    visit "/fake_login"
  end
end

RSpec.configuration.include HelperMethods, :type => :acceptance
