require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Signup Feature" do

  scenario "New user to the site" do
    
    visit '/'
    click_link 'Login'
    
    current_path.should == '/login'
    
  end
  
end
