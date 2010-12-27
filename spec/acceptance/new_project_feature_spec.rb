# coding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')
feature "New Project Feature" do
  scenario "I'm not logged in and I want to send a project. It should ask for login." do
    visit homepage
    click_link 'Envie seu projeto'
    find("#login").visible?.should be_true
  end
  scenario "I am logged in and I want to send a project" do
    visit homepage
    fake_login
    click_link 'Envie seu projeto'
    current_path.should == guidelines_projects_path
    within 'head title' do
      page.should have_content("Como funciona") 
    end    
    within '#content_header' do
      within 'h1' do
        page.should have_content("Como funciona")
      end
    end
    uncheck 'accept'
    find_button('Enviar meu projeto')['disabled'].should == 'true'
    check 'accept'
    find_button('Enviar meu projeto')['disabled'].should == 'false'
    click_button 'Enviar meu projeto'
    current_path.should == new_project_path
    within '#content_header' do
      within 'h1' do
        page.should have_content("Envie seu projeto")
      end
    end
    within '#content' do
    end
  end
end
