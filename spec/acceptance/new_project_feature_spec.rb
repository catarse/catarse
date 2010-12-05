# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "New Project Feature" do

  scenario "I'm not logged in and I want to send a project. It should ask for login." do

    visit homepage

    click_link 'Envie seu projeto'
    click_link 'Twitter'

    if page.has_button? 'Sign in'
      fill_in 'username_or_email', :with => 'catarsetest'
      fill_in 'session[password]', :with => 'testcatarse'
      click_button 'Sign in'
    end
    
    click_button 'Allow' if page.has_button?('Allow')
    
    current_path.should == guidelines_projects_path
    
  end

  scenario "I am logged in and I want to send a project" do

    visit homepage

    fake_login
    click_link 'Envie seu projeto'

    current_path.should == guidelines_projects_path
    
    within 'head title' do
      page.should have_content("Envie seu projeto · Catarse") 
    end    

    within '#content_header' do
      within 'h1' do
        page.should have_content("Envie seu projeto")
      end
      within 'h2' do
        page.should have_content("Mas antes, saiba um pouco mais sobre o que você pode ou não pode fazer no Catarse.")
      end
    end
    
    within '#guidelines' do
      within 'h1' do
        page.should have_content("Melhores práticas no Catarse")
      end
    end
    
  end
  
end
