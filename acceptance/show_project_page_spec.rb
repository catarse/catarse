# encoding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')
feature "Show Project Feature", :driver => :selenium do

  include Rails.application.routes.url_helpers

  scenario "As a user, I want to see a project page" do
    p = Factory.create(:project)
    visit project_path(p)
    within '#project_header' do
      within 'h1' do
        page.should have_content(p.name)
      end
      within 'h2' do
        page.should have_content("Um projeto de #{p.user.name}")
      end
    end
    
    page.should have_css("#project_about")
    within "#project_about" do
      page.should have_content(p.about)
    end
    page.should_not have_css("#project_updates")
    page.should_not have_css("#project_backers")
    page.should_not have_css("#project_comments")

    click_link "Atualizações"
    page.should have_css("#project_updates")
    # within "#project_updates" do
    #   page.should have_content("Este projeto ainda não teve atualizações. Aguarde =D")
    # end
    page.should_not have_css("#project_about")
    page.should_not have_css("#project_backers")
    page.should_not have_css("#project_comments")

    click_link "Apoiadores"
    page.should have_css("#project_backers")
    # within "#project_backers" do
    #   page.should have_content "Ninguém apoiou este projeto ainda. Que tal ser o primeiro?"
    # end
    page.should_not have_css("#project_about")
    page.should_not have_css("#project_updates")
    page.should_not have_css("#project_comments")

    click_link "Comentários"
    page.should have_css("#project_comments")
    page.should_not have_css("#project_about")
    page.should_not have_css("#project_updates")
    page.should_not have_css("#project_backers")

    click_link("Sobre")
    page.should have_css("#project_about")
    within "#project_about" do
      page.should have_content(p.about)
    end
    page.should_not have_css("#project_updates")
    page.should_not have_css("#project_backers")
    page.should_not have_css("#project_comments")
    
  end
end