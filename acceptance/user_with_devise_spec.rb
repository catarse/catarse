require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "with login modal" do
  scenario "Login with user that use another provider" do
    click_login
    verify_translations
    find("#login").visible?.should be_true
    find("a#login_with_mail").click

    user_facebook = Factory.create(:user, :provider => 'facebook', :uid => '1234566',:email => 'lorem@lorem.com', :password => 'somepassword', :password_confirmation => 'somepassword')
    fill_in 'user_email', :with => user_facebook.email
    fill_in 'user_password', :with => user_facebook.password
    click_button 'user_submit'

    page.should have_no_css('#user')
    page.should have_css('.alert.wrapper')
  end

  scenario "Login with devise user" do
    click_login
    verify_translations
    find("#login").visible?.should be_true
    find("a#login_with_mail").click

    user = Factory.create(:user, :provider => 'devise',:email => 'lorem@lorem.com', :password => '123lorem', :password_confirmation => '123lorem')
    fill_in 'user_email', :with => user.email
    fill_in 'user_password', :with => user.password
    click_button 'user_submit'

    page.should have_css('#user')
    page.should have_link(user.name)
  end

  scenario "Register new user account" do
    click_login
    verify_translations
    find("#login").visible?.should be_true
    find("a#login_with_mail").click
    find("a.new_registration_link").click
    verify_translations

    fill_in 'user_name', :with => 'Lorem'
    fill_in 'user_email', :with => 'lorem@lorem.com'
    fill_in 'user_password', :with => '123lorem'
    fill_in 'user_password_confirmation', :with => '123lorem'

    click_button 'user_submit'
    page.should have_css('#user')
  end

  scenario "Request new password" do
    ActionMailer::Base.deliveries.should be_empty

    user = Factory.create(:user, :provider => 'devise',:email => 'lorem@lorem.com', :password => '123lorem', :password_confirmation => '123lorem')
    click_login
    verify_translations
    find("#login").visible?.should be_true
    find("a#login_with_mail").click
    find("a.forgot_password_link").click
    verify_translations
    fill_in 'user_email', :with => user.email
    click_button 'user_submit'

    ActionMailer::Base.deliveries.should_not be_empty
  end
end

feature "with devise routes" do

  scenario "Try login with email that another provider" do
    visit new_user_session_path
    verify_translations
    user_facebook = Factory.create(:user, :provider => 'facebook', :uid => '1234566',:email => 'lorem@lorem.com', :password => 'somepassword', :password_confirmation => 'somepassword')

    fill_in 'user_email', :with => user_facebook.email
    fill_in 'user_password', :with => user_facebook.password
    click_button 'user_submit'

    page.should have_no_css('#user')
    page.should have_css('.alert.wrapper')
  end

  scenario "Login with devise user" do
    visit new_user_session_path
    verify_translations
    user = Factory.create(:user, :provider => 'devise',:email => 'lorem@lorem.com', :password => '123lorem', :password_confirmation => '123lorem')

    fill_in 'user_email', :with => user.email
    fill_in 'user_password', :with => user.password
    click_button 'user_submit'

    page.should have_css('#user')
    page.should have_link(user.name)
  end

  scenario "Register new user using devise" do
    visit new_user_registration_path
    verify_translations

    fill_in 'user_name', :with => 'Lorem'
    fill_in 'user_email', :with => 'lorem@lorem.com'
    fill_in 'user_password', :with => '123lorem'
    fill_in 'user_password_confirmation', :with => '123lorem'
    click_button 'user_submit'
    page.should have_css('#user')
  end

  scenario "Request new password" do
    ActionMailer::Base.deliveries = []
    ActionMailer::Base.deliveries.should be_empty

    user = Factory.create(:user, :provider => 'devise',:email => 'lorem@lorem.com', :password => '123lorem', :password_confirmation => '123lorem')
    visit new_user_password_path
    verify_translations
    page.should have_css('h1', :text => I18n.t('passwords.new.title'))
    fill_in 'user_email', :with => user.email
    click_button 'user_submit'

    ActionMailer::Base.deliveries.should_not be_empty
  end
end
