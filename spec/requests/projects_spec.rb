# coding: utf-8

require 'spec_helper'

describe "Projects" do
  let(:project){ Factory.build(:project) }

  before {
    #NOTE: Weird bug on edit project test
    RoutingFilter.active = true
    ProjectsController.any_instance.stubs(:last_tweets).returns([])
  }
  before {
    ::Configuration[:base_url] = 'http://catarse.me'
    ::Configuration[:company_name] = 'Catarse'
  }


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

  describe "explore" do
    before do
      Factory(:project, name: 'Foo', state: 'online', online_days: 30, recommended: true)
      Factory(:project, name: 'Lorem', state: 'online', online_days: 30, recommended: false)
      visit explore_path(:locale => :pt)
      sleep 2
    end
    it "should show recommended projects" do
      recommended = all(".collection_list .project")
      recommended.should have(1).items
    end
  end

  describe "search" do
    before do
      Factory(:project, name: 'Foo', state: 'online', online_days: 30, recommended: true)
      Factory(:project, name: 'Lorem', state: 'online', online_days: 30, recommended: false)
      visit explore_path(anchor: :search) + '/Lorem'
      sleep 4
    end
    it "should show recommended projects" do
      recommended = all(".collection_list .project")
      recommended.should have(1).items
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

  describe "edit" do
    let(:project) { Factory(:project, online_days: 10, state: 'online', user: current_user) }

    before do
      visit fake_login_path
      visit project_path(project, :locale => :pt)
    end

    it 'edit tab should be present' do
      page.should have_selector('a#edit_link')
    end
  end
end
