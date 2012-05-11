# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "My profile Feature" do

  scenario "I should be able to see and edit my profile when I click on 'meu perfil'" do

    fake_login

    add_some_projects(4, user: user)
    add_some_projects(3)
    7.times do
      Factory(:backer, user: user, confirmed: true)
    end

    click_link user.display_name
    verify_translations
    click_link 'meu perfil'
    verify_translations
    current_path.should == user_path(user)

    within 'head title' do
      page.should have_content("#{user.display_name} · #{I18n.t('site.name')}") 
    end

    within '.profile_title' do
      within 'h1' do
        page.should have_content(user.display_name)
      end
      within 'h4' do
        page.should have_content(user.bio)
      end
    end

    titles = all("#user_profile_menu a")
    titles.shift.should have_content("Projetos apoiados")
    titles.shift.should have_content("Projetos criados")
    titles.shift.should have_content("Créditos")
    titles.shift.should have_content("Preferências")

    # User Settings
    within "#user_profile_menu" do
      click_link "Preferências"
    end
    verify_translations

    within "#my_data ul" do
      page.should have_content(user.email)
      page.should have_css("input[type=checkbox]#newsletter")
    end

    within "#social_info" do
      page.should have_css("input[type=text]#user_twitter")
      page.should have_css("input[type=text]#user_facebook_link")
      page.should have_css("input[type=text]#user_other_link")
      page.should have_css("input[type=submit]#user_submit")
    end

    # My Projects
    within "#user_profile_menu" do
      click_link "Projetos criados"
    end
    verify_translations
    sleep 2

    within "#user_created_projects" do
      all('li .project_land').should have(4).items
    end

    # Backed Projects
    within "#user_profile_menu" do
      click_link "Projetos apoiados"
    end
    verify_translations
    sleep 2

    within "#user_backed_projects" do
      all('li .project_land').should have(7).items
    end

    # Testing on the spot edits
    within '.profile_title' do
      within 'h1' do
        page.should have_no_content("New user name")
        page.should have_content(user.display_name)
        find("span").click
        find("input").set("New user name")
        click_on "OK"
        page.should have_content("New user name")
        user.reload
        user.display_name.should == "New user name"
      end

      within 'h4' do
        page.should have_no_content("New user biography")
        page.should have_content(user.bio)
        find("span").click
        find("textarea").set("New user biography")
        click_on "OK"
        page.should have_content("New user biography")
        user.reload
        user.bio.should == "New user biography"
      end
    end

    within "#user_profile_menu" do
      click_link "Preferências"
    end
    verify_translations

    within "#my_data ul" do
      within first("li") do
        page.should have_no_content("new@email.com")
        page.should have_content(user.email)
        find("span").click
        find("input").set("new@email.com")
        click_on "OK"
        page.should have_content("new@email.com")
        user.reload
        user.email.should == "new@email.com"
      end
    end

    within "#user_profile_menu" do
      click_link "Preferências"
    end
    verify_translations

    within "#social_info" do
      fill_in "twitter ( usuário )", with: "@FooBar"
      fill_in "perfil do facebook", with: "facebook.com/FooBar"
      fill_in "link da sua página na internet", with: "boobar.com"
      click_button "Atualizar informações"
    end
    verify_translations

    within "#social_info" do
      find_field("twitter ( usuário )").value.should == "FooBar"
      find_field("perfil do facebook").value.should == "facebook.com/FooBar"
      find_field("link da sua página na internet").value.should == "boobar.com"
    end

  end

end
