require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Logout Feature" do

  scenario "Given I'm logged in, I must be able to logout" do

    login

    page.should have_link('Foo bar')

    click_link "Foo bar"
    click_link "Logout"

    page.should have_no_link('Foo bar')
  
  end

end
