require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Logout Feature" do

  scenario "Given I'm logged in, I must be able to logout" do

    @current_user = Factory(:user)

    visit homepage

    page.should have_no_selector('#login_link')

    click_link @current_user.display_name
    click_link "Logout"

    page.should have_selector('#login_link')

  end

end

