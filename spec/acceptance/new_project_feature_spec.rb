require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "New Project Feature" do

  scenario "I'm not logged in and I want to send a project" do

    visit homepage
    
    click_link 'Envie seu projeto'
    click_link 'Twitter'

    fill_in 'username_or_email', :with => 'catarsetest'
    fill_in 'session[password]', :with => 'testcatarse'
    click_button 'Sign in'

    current_path.should == new_project_path
    
  end

  scenario "I am logged in and I want to send a project" do

    visit homepage

    fake_login
    click_link 'Envie seu projeto'

    current_path.should == new_project_path
    
  end
  
end
