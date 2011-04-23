module HelperMethods
  # Put helper methods you need to be available in all tests here.
  def current_site
    return @current_site if @current_site
    @current_site = Site.find_by_path("catarse")
    @current_site = Factory(:site, :name => "Catarse", :path => "catarse") unless @current_site
    @current_site
  end
  def fake_login
    visit fake_login_path
  end
  def user
    User.find_by_uid 'fake_login'
  end
  def click_login
    visit homepage
    page.should have_no_css('#user')
    click_link 'Login'
  end
end
RSpec.configuration.include HelperMethods, :type => :acceptance
