require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Login Feature" do

  scenario "I'm new to the site and I want to signup with twitter" do

    visit homepage
    click_link 'Login'
    click_link 'Twitter'

    pending "I couldn't find out how to stub /auth/twitter to go directly to /auth/twitter/callback...I think this is the way to test it, without having to go to Twitter."

  end

end

