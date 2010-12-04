module HelperMethods
  # Put helper methods you need to be available in all tests here.
  def login
    visit "/fake_login"
  end
  def user
    User.find_by_uid 'fake_login'
  end
end

RSpec.configuration.include HelperMethods, :type => :acceptance
