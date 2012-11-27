# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Send Project Feature", :driver => :selenium do

  scenario "I'm not logged in and I want to send a project. It should ask for login." do
    visit homepage
    click_link 'envie'
    current_path.should == guidelines_path
  end

  scenario "I am logged in and I want to send a project" do

    c = Factory(:category)
    visit homepage
    fake_login
    click_link 'envie'
    current_path.should == guidelines_path

    within 'head title' do
      page.should have_content("Como funciona")
    end

    within '.title' do
      within 'h1' do
        page.should have_content("Como funciona")
      end
    end

    click_link I18n.t('static.guidelines.submit')
    sleep 1
    click_link I18n.t('static.guidelines_tips.submit')

    current_path.should == start_projects_path
    Factory(:notification_type, :name => 'project_received')

    within '.bootstrap-form' do
      fill_in 'how_much_you_need', with: 10
      fill_in 'about', :with => 'about this very cool project'
      fill_in 'rewards', :with => 'rewards of this very cool project'
      fill_in 'links', :with => 'links of this very cool project'
      fill_in 'contact', :with => 'foo@bar.com'
      check 'accept'
      verify_translations
      click_button 'Enviar o projeto'
    end

    ActionMailer::Base.deliveries.should_not be_empty
    current_path.should == homepage

  end

end
