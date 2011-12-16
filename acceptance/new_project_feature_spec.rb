# coding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')
feature "New Project Feature", :driver => :selenium do

  scenario "I'm not logged in and I want to send a project. It should ask for login." do
    visit homepage
    click_link 'Envie seu projeto'
    find("#login").visible?.should be_true
  end

  scenario "I am logged in and I want to send a project" do
    c = Factory(:category)
    visit homepage
    fake_login
    visit new_project_path
    current_path.should == new_project_path
    within '#content_header' do
      within 'h1' do
        page.should have_content("Envie seu projeto")
      end
    end

    within '#content' do
      sleep 2
      fill_in 'project_name', :with => 'test project'

      fill_in 'project_video_url', :with => 'http://vimeo.com/18210052'
      fill_in 'project_about', :with => 'about this very cool project'
      fill_in 'project_headline', :with => 'this is our nice headline'
      fill_in 'project_goal', :with => '1000'
      fill_in 'project_expires_at', :with => '21/12/2012'
      fill_in 'project_rewards_attributes_0_description', :with => 'this is an exciting reward'
      fill_in 'project_rewards_attributes_0_minimum_value', :with => '10'
      select c.name, :from => 'project_category_id'
      check 'accept'
      click_button 'project_submit'
    end

    p = Project.first
    p.name.should == 'test project'
    p.expires_at.should == Time.parse('2012-12-21') + (23.hours + 59.minutes + 59.seconds)
    page.should have_content("test project")
  end
end

