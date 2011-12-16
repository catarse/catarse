# coding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "View curated page" do
  scenario "I should see a curated page" do
    p1 = Factory.build(:project)
    p1.save
    p2 = Factory.build(:project)
    p2.save
    p3 = Factory.build(:project)
    p3.save

    cp = Factory.build(:curated_page)
    cp.projects << p1
    cp.projects << p2
    cp.projects << p3
    cp.save
    
    visit "/#{cp.permalink}"
    verify_translations
    
    within '#index_header_text' do
      within 'h1' do
        page.should have_content(cp.name)
      end
      within 'h2' do
        page.should have_content(cp.description)
      end
    end
    
    within "#content" do
      page.should have_css(".project_box", :count => cp.projects.count)
    end
  end
end