# coding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "My profile Feature" do
  before do
    Factory(:notification_type, name: 'updates')
  end

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

  scenario "I should be able to see my backed projects" do
    fake_login
    7.times do
      Factory(:backer, user: current_user, confirmed: true)
    end
    click_link I18n.t('layouts.header.account')
    click_link I18n.t('layouts.header.profile')

    # Backed Projects
    within "#user_profile_menu" do
      click_link I18n.t('users.show.tabs.backed_projects')
    end
    sleep 5

    within "#user_backed_projects" do
      all('li .project_land').should have(7).items
    end
  end

  scenario "I should be able to see my created projects" do
    fake_login
    4.times{ Factory(:project, user: current_user, state: 'online') }
    3.times{ Factory(:project, state: 'online') }
    click_link I18n.t('layouts.header.account')
    click_link I18n.t('layouts.header.profile')

    # My Projects
    within "#user_profile_menu" do
      click_link I18n.t('users.show.tabs.created_projects')
    end
    sleep 5

    within "#user_created_projects" do
      all('li .small_project_land').should have(4).items
    end
  end

  scenario "I should be able to see and edit my profile when I click on 'meu perfil'" do
    fake_login
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

    within "#my_data" do
      fill_in I18n.t('users.current_user_fields.twitter'), with: "@FooBar"
      fill_in I18n.t('users.current_user_fields.facebook_link'), with: "facebook.com/FooBar"
      fill_in I18n.t('users.current_user_fields.other_link'), with: "boobar.com"
      click_button I18n.t('users.current_user_fields.update_social_info')
      # After saving
      current_user.twitter.should == 'FooBar'
      current_user.facebook_link.should == 'facebook.com/FooBar'
      current_user.other_link.should == 'boobar.com'
    end
  end
end
