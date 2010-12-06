require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Login Feature" do

  scenario "I open the login page but then I cancel" do
    click_login
    find("#login").visible?.should be_true
    click_link 'X'
    current_path.should == homepage
    find("#login").visible?.should be_false
  end

  scenario "I'm new to the site and I want to signup with Twitter" do
    click_login
    click_link 'Twitter'
    if page.has_button? 'Sign in'
      fill_in 'username_or_email', :with => 'catarsetest'
      fill_in 'session[password]', :with => 'testcatarse'
      click_button 'Sign in'
    end
    click_button 'Allow' if page.has_button?('Allow')
    save_and_open_page
    current_path.should == homepage
    page.should have_css('#user')
    page.should have_link('Catarse Test')
  end

  scenario "I'm new to the site and I want to signup with Google" do
    click_login
    click_link 'Google'
    if page.has_button? 'signIn'
      fill_in 'Email', :with => 'catarsetest'
      fill_in 'Passwd', :with => 'testcatarse'
      click_button 'signIn'
    end
    click_button 'approve_button' if page.has_button?('approve_button')
    current_path.should == homepage
    page.should have_css('#user')
  end
end
