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
    within ".title" do
      page.should have_css('h1', :text => 'Gerenciamento dos projetos')
    end
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
    visit homepage
    verify_translations
    page.should have_no_css('.project_list_header')
    visit pending_projects_path
    check 'project__visible__1'
    verify_translations
    # Had to add this sleep to wait for ajax to update the records
    sleep 4
    visit homepage
    verify_translations
    page.should have_css('.title h2', :text => "novos e fresquinhos")
    page.should have_css('.recents_projects')
    all('.recents_projects .projects .curated_project').should have(1).item
    within '.recents_projects' do
      page.should have_css '.projects .curated_project h4', :text => 'Foo bar 0'
    end
  end

end
