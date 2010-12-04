# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Profile Feature" do

  scenario "I should be able to see and edit my profile when I click on 'Meu perfil'" do

    login
    
    click_link user.display_name
    click_link 'Meu perfil'

    current_path.should == "/users/#{user.id}"
    
    within 'head title' do
      page.should have_content("#{user.display_name} · Catarse") 
    end    

    within '#content_header' do
      find('img')[:src].should match /#{user.display_image}/
      within 'h1' do
        page.should have_content(user.display_name)
      end
      within 'h2' do
        page.should have_content(user.bio)
      end
    end
    
  end
end
