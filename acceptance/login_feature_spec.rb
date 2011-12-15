require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')
feature "Login Feature" do
  scenario "I open the login page but then I cancel" do
    click_login
    find("#login").visible?.should be_true
    click_link 'X'
    current_path.should == homepage
    find("#login").visible?.should be_false
  end

  scenario "I'm new to the platform and I want to signup with a supported provider" do
    click_login
    page.should have_link('Google')
    page.should_not have_link('Github')

    fake_login
    page.should have_css('#user')
    page.should have_link(user.name)
  end

  scenario "After insertion of a new provider it should appear in the login options" do
    Factory(:oauth_provider)
    sleep 3
    click_login
    page.should have_link('Google')
    page.should have_link('Github')
  end
end
