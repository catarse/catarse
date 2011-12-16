module HelperMethods

  # Put helper methods you need to be available in all tests here.

  def fake_login
    visit fake_login_path
  end

  def user
    User.find_by_uid 'fake_login'
  end
  alias_method :current_user, :user

  def click_login
    visit homepage
    page.should have_no_css('#user')
    click_link 'Entrar'
  end

  def user_to_admin user
    user.admin=true
    user.save
    user.reload
  end

  def add_some_projects(num_of_projects=5)
    num_of_projects.times do |n|
      project = create(:project, :name => "Foo bar #{n}")
    end
  end
end
RSpec.configuration.include HelperMethods, :type => :acceptance
