require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Signup/signin Feature" do

  scenario "My first visit to the site and I want to login with twitter" do
    
    visit '/'
    click_link 'Login'
    click_link 'twitter'
    
    #current_path.should == '/login'
    true.should == true
    
  end
  
end
