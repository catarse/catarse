# encoding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')
feature "Show Project Feature", :driver => :selenium do

  include Rails.application.routes.url_helpers

  scenario "when I access a project it should show me the facebook meta tags" do
    p = Factory(:project, :short_url => 'http://catr.se/teste')
    visit project_path(p.id)
    verify_translations
    page.should have_css(%@meta [property="og:title"][content="#{p.name}"]@)
    page.should have_css(%@meta [property="og:type"][content="cause"]@)
    page.should have_css(%@meta [property="og:url"][content="#{I18n.t('site.base_url')}#{project_path(p)}"]@)
    page.should have_css(%@meta [property="og:image"][content="#{p.display_image}"]@)
    page.should have_css(%@meta [property="og:site_name"][content="#{I18n.t('site.name')}"]@)
    page.should have_css(%@meta [property="og:description"][content="#{p.about}"]@)
  end

  scenario "As a user, I want to see a project page" do
    p = Factory.create(:project)
    visit project_path(p)
    verify_translations
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
    verify_translations
    page.should have_css("#project_updates")
    page.should have_content("Este projeto ainda não teve atualizações. Aguarde =D")
    page.should_not have_css("#project_about")
    page.should_not have_css("#project_backers")
    page.should_not have_css("#project_comments")

    click_link "Apoiadores"
    verify_translations
    page.should have_css("#project_backers")
    page.should have_content "Ninguém apoiou este projeto ainda. Que tal ser o primeiro?"
    page.should_not have_css("#project_about")
    page.should_not have_css("#project_updates")
    page.should_not have_css("#project_comments")

    click_link "Comentários"
    verify_translations
    page.should have_css("#project_comments")
    page.should_not have_css("#project_about")
    page.should_not have_css("#project_updates")
    page.should_not have_css("#project_backers")

    click_link("Sobre")
    verify_translations
    page.should have_css("#project_about")
    within "#project_about" do
      page.should have_content(p.about)
    end
    page.should_not have_css("#project_updates")
    page.should_not have_css("#project_backers")
    page.should_not have_css("#project_comments")
    
  end
end