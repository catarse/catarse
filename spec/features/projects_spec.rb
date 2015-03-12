# coding: utf-8

require 'rails_helper'

RSpec.describe "Projects", type: :feature do
  let(:project){ build(:project) }

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
    before do
      11.times{ create(:project, name: 'Foo', state: 'online', online_days: 30, recommended: true) }
      create(:project, name: 'Lorem', state: 'online', online_days: 30, recommended: false)
      visit explore_path(locale: :pt)
      sleep FeatureHelpers::TIME_TO_SLEEP
    end

    it "should show recommended projects" do
      recommended = all(".results .card-project")
      expect(recommended.size).to eq(6)
    end

    it "should load 6 more projects after clicking load more and then hide it" do
      click_on("load-more")
      sleep FeatureHelpers::TIME_TO_SLEEP
      results = all(".results .card-project")
      expect(results.size).to eq(11)
      expect(page.evaluate_script('$("#load-more:visible").length')).to eq(0)
    end
  end

  describe "view" do
    before do
      20.times{ create(:contribution, value: 10.00, credits: true, project: project, state: 'confirmed') }
      6.times{ create(:project_post, project: project) }
      visit project_path(project)
      sleep FeatureHelpers::TIME_TO_SLEEP
    end

    it "should show 20 contributions when clicking on the contributors tab" do
      click_on("contributions_link")
      sleep FeatureHelpers::TIME_TO_SLEEP
      contributors = all(".results .u-marginbottom-20")
      expect(contributors.size).to eq(20)
    end

    it "should load 20 more contributions after click load more and then hide it" do
      click_on("contributions_link")
      sleep FeatureHelpers::TIME_TO_SLEEP
      click_on("load-more")
      sleep FeatureHelpers::TIME_TO_SLEEP
      contributors = all(".results .u-marginbottom-20")
      expect(contributors.size).to eq(40)
      expect(page.evaluate_script('$("#load-more:visible").length')).to eq(0)
    end

    it "should show 3 posts when clicking on the posts tab" do
      click_on("posts_link")
      sleep FeatureHelpers::TIME_TO_SLEEP
      posts = all(".posts .project-news")
      expect(posts.size).to eq(3)
    end

    it "should load 3 more contributions after click load more and then hide it" do
      click_on("posts_link")
      sleep FeatureHelpers::TIME_TO_SLEEP
      click_on("load-more")
      sleep FeatureHelpers::TIME_TO_SLEEP
      posts = all(".posts .project-news")
      expect(posts.size).to eq(6) 
      expect(page.evaluate_script('$("#load-more:visible").length')).to eq(0)
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
    pending 'NEED TEST ON EDIT PROJECT'
  end

end