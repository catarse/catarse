# coding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')
feature "My profile Feature" do
  scenario "I should be able to see and edit my profile when I click on 'Meu perfil'" do
    fake_login
    click_link user.display_name
    click_link 'Meu perfil'
    current_path.should == user_path(user)
    within 'head title' do
      page.should have_content("#{user.display_name} · #{I18n.t('site.name')}") 
    end
    within '#content_header' do
      within 'h1' do
        page.should have_content(user.display_name)
      end
      within 'h2' do
        page.should have_content(user.bio)
      end
    end
    pending "I still don't have the complete profile, and I still can't edit it."
  end
end
