# coding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Manage pending projects" do

  before do
    fake_login
  end

  scenario "with non admin user" do
    visit pending_projects_path
    page.should have_css('.failure.wrapper')
  end

  scenario "with admin user" do
    user_to_admin(current_user)
    visit pending_projects_path(:locale => 'en')
    page.should_not have_css('.failure.wrapper')
    page.should have_css('#content_header', :text => 'Project management')
  end

  scenario "show a table with projects" do
    add_some_projects(10)
    user_to_admin(current_user)
    visit pending_projects_path(:locale => 'en')
    page.should have_content "Found 10 projects"
    all("#pending_projects table tbody tr").should have(10).itens
  end

  scenario 'show projects in home page' do
    add_some_projects(1)
    user_to_admin(current_user)
    visit root_path(:locale => 'en')
    page.should_not have_css('.project_list_header')
    visit pending_projects_path(:locale => 'en')
    check 'projects__visible__1'
    check 'projects__home_page__1'
    visit root_path(:locale => 'en')

    page.should have_css('.project_list_header', :text => "Our cathartic selection!")
    page.should have_css('#home_page_projects')
    all('#home_page_projects .project_box').should have(1).item

    within '#home_page_projects' do
      page.should have_css '.project_box .project_header', :text => 'Foo bar 0'
    end
  end
end