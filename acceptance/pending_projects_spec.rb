# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Pending projects" do

  before do
    fake_login
  end

  scenario "with non admin user" do
    visit pending_projects_path
    verify_translations
    page.should have_css('.failure.wrapper')
  end

  scenario "with admin user" do
    user_to_admin(current_user)
    visit pending_projects_path
    verify_translations
    page.should have_no_css('.failure.wrapper')
    page.should have_css('#content_header', :text => 'Gerenciamento dos projetos')
  end

  scenario "show a table with projects" do
    add_some_projects(10)
    user_to_admin(current_user)
    visit pending_projects_path
    verify_translations
    page.should have_content "Encontrados 10 projetos"
    all("#pending_projects table tbody tr").should have(10).itens
  end

  scenario 'show projects in home page' do
    add_some_projects(1)
    user_to_admin(current_user)
    visit root_path
    verify_translations
    page.should have_no_css('.project_list_header')
    visit pending_projects_path
    check 'project__visible__1'
    check 'project__home_page__1'
    verify_translations
    # Added a sleep to see if this spec pass on Travis-CI
    sleep 2
    visit root_path
    verify_translations
    page.should have_css('.project_list_header', :text => "Nossa seleção catártica!")
    page.should have_css('#home_page_projects')
    all('#home_page_projects .project_box').should have(1).item
    within '#home_page_projects' do
      page.should have_css '.project_box .project_header', :text => 'Foo bar 0'
    end
  end

end