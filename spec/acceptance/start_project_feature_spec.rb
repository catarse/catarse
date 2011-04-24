# coding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')
feature "Send Project Feature" do
  scenario "I'm not logged in and I want to send a project. It should ask for login." do
    visit homepage
    click_link 'Envie seu projeto'
    find("#login").visible?.should be_true
  end
  scenario "I am logged in and I want to send a project" do
    c = Factory(:category) 
    visit homepage
    fake_login
    click_link 'Envie seu projeto'
    current_path.should == guidelines_path
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
    current_path.should == start_projects_path
    within '#content_header' do
      within 'h1' do
        page.should have_content("Envie seu projeto")
      end
    end
    within '#content' do
      fill_in 'about', :with => 'about this very cool project'
      fill_in 'rewards', :with => 'rewards of this very cool project'
      fill_in 'links', :with => 'links of this very cool project'
      fill_in 'contact', :with => 'foo@bar.com'
      check 'accept'
      click_button 'Enviar o projeto'
    end
    ActionMailer::Base.deliveries.should_not be_empty
    current_path.should == homepage
  end
end
