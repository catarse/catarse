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
    
    # Testing on the spot edits
    
    within '#content_header' do
      within 'h1' do
        page.should have_no_content("New user name")
        page.should have_content(user.display_name)
        find("span").click
        find("input").set("New user name")
        click_on "OK"
        page.should have_no_content(user.display_name)
        page.should have_content("New user name")
        user.reload
        user.display_name.should == "New user name"
      end
      within 'h2' do
        page.should have_no_content("New user biography")
        page.should have_content(user.bio)
        find("span").click
        find("textarea").set("New user biography")
        click_on "OK"
        page.should have_no_content(user.bio)
        page.should have_content("New user biography")
        user.reload
        user.bio.should == "New user biography"
      end
    end
    
    within first("#user_feed ul") do
      within first("li") do
        page.should have_no_content("new@email.com")
        page.should have_content(user.email)
        find("span").click
        find("input").set("new@email.com")
        click_on "OK"
        page.should have_no_content(user.email)
        page.should have_content("new@email.com")
        user.reload
        user.email.should == "new@email.com"
      end
    end
    
  end

end
