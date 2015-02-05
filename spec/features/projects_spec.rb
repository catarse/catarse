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
      create(:project, name: 'Foo', state: 'online', online_days: 30, recommended: true)
      create(:project, name: 'Lorem', state: 'online', online_days: 30, recommended: false)
      visit explore_path(locale: :pt)
      sleep 4
    end
    it "should show recommended projects" do
      recommended = all(".results .card-project")
      expect(recommended.size).to eq(1)
    end
  end

  describe "search" do
    before do
      create(:project, name: 'Foo', state: 'online', online_days: 30, recommended: true)
      create(:project, name: 'Lorem', state: 'online', online_days: 30, recommended: false)
      visit explore_path(pg_search: 'Lorem')
      sleep 4
    end
    it "should show recommended projects" do
      recommended = all(".results .card-project")
      expect(recommended.size).to eq(1)
    end
  end


  describe "new and create" do
    pending "NEED TEST ON CREATING PROJECT"
  end
  #describe "new and create" do
  #  before do
  #    project # need to build the project to create category before visiting the page
  #    login
  #    visit new_project_path(locale: :pt)
  #    sleep 1
  #  end

  #  it "should present the form and save the data" do
  #    expect(all("form#project_form").size).to eq(1)
  #    [
  #      'permalink', 'name', 'video_url',
  #      'headline', 'goal', 'online_days',
  #      'about'
  #    ].each do |a|
  #      fill_in "project_#{a}", with: project.attributes[a]
  #    end
  #    find('#project_submit').click
  #  end
  #end


  describe "edit" do
    pending 'NEED TEST ON EDIT PROJECT'
  end
  #describe "edit" do
  #  let(:project) { create(:project, online_days: 10, state: 'online', user: current_user) }

  #  before do
  #    login
  #    visit project_path(project, locale: :pt)
  #  end

  #  it 'edit tab should be present' do
  #    expect(page).to have_selector('a#edit_link')
  #  end
  #end
end
