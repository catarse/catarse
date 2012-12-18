module HelperMethods

  # Put helper methods you need to be available in all tests here.

  def fake_login
    visit '/fake_login'
  end

  def user
    User.find_by_uid 'fake_login'
  end
  alias_method :current_user, :user

  def click_login
    visit homepage
    page.should have_no_css('.user')
    click_link 'login'
  end

  def user_to_admin user
    user.admin=true
    user.save
    user.reload
  end

  def add_some_projects(num_of_projects=5, attributes={})
    num_of_projects.times do |n|
      create(:project, {name: "Foo bar #{n}"}.merge(attributes))
    end
  end

  def verify_translations
    page.should have_no_css('.translation_missing')
    page.should have_no_content('translation missing')
  end

  def click_on(locator)
    super(locator)
    verify_translations
  end

  def click_link(locator, options = {})
    super(locator, options)
    verify_translations
  end

  def visit(url)
    super(url)
    verify_translations
  end

end

RSpec.configuration.include HelperMethods, :type => :acceptance
