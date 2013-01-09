# coding: utf-8

require 'spec_helper'

describe "Projects" do
  let(:project){ Factory.build(:project) }

  describe "home" do
    before do
      Factory(:project, state: 'online', online_days: 30)
      Factory(:project, state: 'online', online_days: -30)
      visit root_path(:locale => :pt)
    end 

    it "should show recent projects" do
      recent = all(".recents_projects.list .projects .curated_project")
      recent.should have(1).items
    end
  end

  describe "new and create" do
    before do
      visit fake_login_path
      visit new_project_path(:locale => :pt)
    end

    it "should present the form and save the data" do
      all("form#project_form").should have(1).items
      [
        'permalink', 'name', 'video_url', 
        'headline', 'goal', 'online_days', 
        'about', 'first_backers', 'how_know', 'more_links'
      ].each do |a|
        fill_in "project_#{a}", with: project.attributes[a]
      end
      check 'accept'
      click_on 'project_submit'
      #Project.first.name.should == project.name
    end
  end
end
