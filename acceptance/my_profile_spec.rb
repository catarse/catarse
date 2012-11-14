# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "My profile Feature" do

  scenario "I should be able to upload a custom avatar" do
    fake_login
    click_link I18n.t('layouts.header.account')
    click_link I18n.t('layouts.header.profile')
    click_link I18n.t('users.show.tabs.settings')
    attach_file('user_uploaded_image', "#{Rails.root}/spec/fixtures/image.png")
    click_button('image_upload_btn')
    sleep 2
    current_user.uploaded_image.url.should_not be_nil
  end

  scenario "I should be able to see and edit my profile when I click on 'meu perfil'" do

    fake_login

    add_some_projects(4, user: user)
    add_some_projects(3)
    7.times do
      Factory(:backer, user: user, confirmed: true)
    end

    click_link I18n.t('layouts.header.account')
    click_link I18n.t('layouts.header.profile')
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
    titles.shift.should have_content(I18n.t('users.show.tabs.backed_projects'))
    titles.shift.should have_content(I18n.t('users.show.tabs.created_projects'))
    titles.shift.should have_content(I18n.t('users.show.tabs.credits'))
    titles.shift.should have_content(I18n.t('users.show.tabs.settings'))

    # User Settings
    within "#user_profile_menu" do
      click_link I18n.t('users.show.tabs.settings')
    end

    within "#my_data ul" do
      page.should have_content(user.email)
      #page.should have_css("input[type=checkbox]#newsletter")
    end

    within "#my_data" do
      page.should have_css("input[type=text]#user_twitter")
      page.should have_css("input[type=text]#user_facebook_link")
      page.should have_css("input[type=text]#user_other_link")
      page.should have_css("input[type=submit]#user_submit")
    end

    # My Projects
    within "#user_profile_menu" do
      click_link I18n.t('users.show.tabs.created_projects')
    end
    sleep 5

    within "#user_created_projects" do
      all('li .small_project_land').should have(4).items
    end

    # Backed Projects
    within "#user_profile_menu" do
      click_link I18n.t('users.show.tabs.backed_projects')
    end
    sleep 5

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
      click_link I18n.t('users.show.tabs.settings')
    end

    within "#my_data ul" do
      page.should have_no_content("new@email.com")
      page.should have_content(user.email)
      find("span").click
      within 'span' do
        find("input").set("new@email.com")
        click_on "OK"
      end
      page.should have_content("new@email.com")
      user.reload
      user.email.should == "new@email.com"
    end

    within "#user_profile_menu" do
      click_link I18n.t('users.show.tabs.settings')
    end

    within "#my_data" do
      fill_in I18n.t('users.current_user_fields.twitter'), with: "@FooBar"
      fill_in I18n.t('users.current_user_fields.facebook_link'), with: "facebook.com/FooBar"
      fill_in I18n.t('users.current_user_fields.other_link'), with: "boobar.com"
      click_button I18n.t('users.current_user_fields.update_social_info')
    end
    verify_translations

    within "#my_data" do
      find_field(I18n.t('users.current_user_fields.twitter')).value.should == "FooBar"
      find_field(I18n.t('users.current_user_fields.facebook_link')).value.should == "facebook.com/FooBar"
      find_field(I18n.t('users.current_user_fields.other_link')).value.should == "boobar.com"
    end

  end

end
