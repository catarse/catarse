# coding: utf-8

require 'rails_helper'

RSpec.describe "Projects", type: :feature do
  let(:project){ build(:project, state: 'online') }

  before {
    #NOTE: Weird bug on edit project test
    RoutingFilter.active = true
  }
  before {
    CatarseSettings[:base_url] = 'http://catarse.me'
    CatarseSettings[:company_name] = 'Catarse'
  }

  describe "home" do
    before do
      create(:project, state: 'online', online_days: 30, online_date: Time.now)
      create(:project, state: 'online', online_days: 30, online_date: 7.days.ago)
      visit root_path(locale: :pt)
    end

    it "should show recent projects" do
      recent = all(".recent-projects .card-project")
      expect(recent.size).to eq(1)
    end
  end

  describe "explore" do
    let(:category_1) { create(:category) }
    let(:category_2) { create(:category) }

    before do
      1.times{ create(:project, name: 'Foo', category: category_1, state: 'online', online_days: 30, recommended: false) }
      4.times{ create(:project, name: 'Foo', category: category_1, state: 'online', online_days: 30, recommended: true) }
      18.times{ create(:project, name: 'Bar', category: category_2, state: 'online', online_days: 30, recommended: true) }
      create(:project, category: category_2, name: 'Lorem', state: 'online', online_days: 30, recommended: false)
      visit explore_path(locale: :pt)
      sleep FeatureHelpers::TIME_TO_SLEEP
    end

    it "should show recommended projects" do
      recommended = all(".results .card-project")
      expect(recommended.size).to eq(18)
    end

    it "should load 4 more projects after clicking load more and then hide it" do
      click_on("load-more")
      sleep FeatureHelpers::TIME_TO_SLEEP
      results = all(".results .card-project")
      expect(results.size).to eq(22)
      expect(page.evaluate_script('$("#load-more:visible").length')).to eq(0)
    end

    it "should load 5 projects from specific category when clicking on its filter" do
      find(:css, "a[data-categoryid=\"1\"]").click
      sleep FeatureHelpers::TIME_TO_SLEEP
      results = all(".results .card-project")
      expect(results.size).to eq(5)
    end
  end

  describe "view" do
    before do
      20.times{ create(:confirmed_contribution, value: 10.00, project: project) }
      6.times{ create(:project_post, project: project) }
      visit project_path(project)
      sleep FeatureHelpers::TIME_TO_SLEEP
    end

    it "should show 10 contributions when clicking on the contributors tab" do
      click_on("contributions_link")
      sleep FeatureHelpers::TIME_TO_SLEEP
      contributors = all(".results .w-clearfix")
      expect(contributors.size).to eq(10)
    end

    it "should load 10 more contributions after click load more and then hide it" do
      click_on("contributions_link")
      sleep FeatureHelpers::TIME_TO_SLEEP
      click_on("load-more")
      sleep FeatureHelpers::TIME_TO_SLEEP
      contributors = all(".results .w-clearfix")
      expect(contributors.size).to eq(20)
      expect(page.evaluate_script('$("#load-more:visible").length')).to eq(0)
    end

    it "should show 3 project news posts when clicking on the posts tab" do
      click_on("posts_link")
      sleep FeatureHelpers::TIME_TO_SLEEP
      posts = all(".posts .project-news")
      expect(posts.size).to eq(3)
    end

    it "should load 3 more project news posts after click load more and then hide it" do
      click_on("posts_link")
      sleep FeatureHelpers::TIME_TO_SLEEP
      click_on("load-more")
      sleep FeatureHelpers::TIME_TO_SLEEP
      posts = all(".posts .project-news")
      expect(posts.size).to eq(6) 
      expect(page.evaluate_script('$("#load-more:visible").length')).to eq(0)
    end

    it "should navigate to the project reward selection page after clicking on a reward card" do
      find(:css, '.card-reward').click
      uri = URI.parse(current_url)
      expect(new_project_contribution_path(project, reward_id: 1)).to eq("#{uri.path}?#{uri.query}")
    end
  end

  describe "view_own_project" do
    before do
      login
      @own_project = create(:project, user: current_user)
      10.times{ create(:confirmed_contribution, value: 10.00, project: @own_project) }
      5.times{ create(:pending_contribution, value: 10.00, project: @own_project) }
      visit project_path(@own_project)
    end
    
    it "should view 5 pending contributions" do
      click_on("contributions_link")
      choose("contribution_state_waiting_confirmation")
      sleep FeatureHelpers::TIME_TO_SLEEP
      contributions = all(".results .w-clearfix")
      expect(contributions.size).to eq(5)
    end
  end

  describe "search" do
    before do
      create(:project, name: 'Foo', state: 'online', online_days: 30, recommended: true)
      create(:project, name: 'Lorem', state: 'online', online_days: 30, recommended: false)
      visit explore_path(pg_search: 'Lorem')
      sleep FeatureHelpers::TIME_TO_SLEEP
    end

    it "should show matching projects" do
      recommended = all(".results .card-project")
      expect(recommended.size).to eq(1)
    end
  end

  describe "new and create" do
    pending "NEED TEST ON CREATING PROJECT"
  end

  describe "edit" do
    before do
      login
      @own_project = create(:project, user: current_user)
      visit edit_project_path(@own_project, anchor: :posts)
    end
    
    it "should post project post" do
      sleep FeatureHelpers::TIME_TO_SLEEP
      fill_in "project_posts_attributes_0_title", with: 'Foo title'
      page.execute_script( "$('.redactor').redactor('code.set', 'Bar')" )
      click_button(I18n.t('projects.dashboard_posts.publish'))
      expect(page).to have_content('Foo title')
    end
  end
end
