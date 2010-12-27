require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')
feature "Login Feature" do
  scenario "I open the login page but then I cancel" do
    click_login
    find("#login").visible?.should be_true
    click_link 'X'
    current_path.should == homepage
    find("#login").visible?.should be_false
  end

  scenario "I'm new to the site and I want to signup with a supported provider" do
    click_login
    ['Twitter', 'Google', 'Github', 'Facebook', 'Yahoo', 'Myspace', 'Linkedin'].each do |provider|
      page.should have_link(provider)
    end
    fake_login
    page.should have_css('#user')
    page.should have_link(user.name)
  end
end
