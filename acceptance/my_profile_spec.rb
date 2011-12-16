# coding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')
feature "My profile Feature" do

  scenario "I should be able to see and edit my profile when I click on 'Meu perfil'" do

    fake_login

    add_some_projects(4, user: user)
    add_some_projects(3)
    7.times do
      Factory(:backer, user: user, confirmed: true)
    end

    click_link user.display_name
    verify_translations
    click_link 'Meu perfil'
    verify_translations
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

    titles = all("#user_feed h1")
    titles.shift.should have_content("Meus dados")
    titles.shift.should have_content("Meus projetos")
    titles.shift.should have_content("Projetos que já apoiei")

    lists = all("#user_feed ul")
    info = lists.shift
    within info do
      page.should have_content(user.email)
      page.should have_css("input[type=checkbox]#newsletter")
    end

    my_projects = lists.shift
    within my_projects do
      all('li').should have(4).items
    end
    
    backed_projects = lists.shift
    within backed_projects do
      all('li').should have(7).items
    end
    
  end

end
