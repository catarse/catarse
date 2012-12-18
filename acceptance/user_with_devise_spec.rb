require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "with login page" do
  before do
    ActionMailer::Base.deliveries.clear
  end

  scenario "Login with user that use another provider" do
    click_login

    user_facebook = Factory.create(:user, :provider => 'facebook', :uid => '1234566',:email => 'lorem@lorem.com', :password => 'somepassword', :password_confirmation => 'somepassword')
    within ".new_session" do
      fill_in 'user_email', :with => user_facebook.email
      fill_in 'user_password', :with => user_facebook.password
      click_button 'user_submit'
    end
    verify_translations

    page.should have_no_css('.user')
    page.should have_css('.alert.wrapper')
  end

  scenario "Login with devise user" do
    click_login

    user = Factory.create(:user, :provider => 'devise',:email => 'lorem@lorem.com', :password => '123lorem', :password_confirmation => '123lorem')
    within ".new_session" do
      fill_in 'user_email', :with => user.email
      fill_in 'user_password', :with => user.password
      click_button 'user_submit'
    end

    page.should have_css('.user')
    page.should have_link(I18n.t('layouts.header.account'))
  end

  scenario "Register new user account" do
    click_login

    within ".new_registration" do
      fill_in "Nome", with: "Foo Bar"
      fill_in "Email", with: "foo@bar.com"
      fill_in "Senha", with: "foo!bar"
      fill_in "user_password_confirmation", with: "foo!bar"
      click_button "Efetuar cadastro"
    end
    verify_translations
    page.should have_css('.user')
  end

  scenario "Request new password" do
    ActionMailer::Base.deliveries.should be_empty

    user = Factory.create(:user, :provider => 'devise',:email => 'lorem@lorem.com', :password => '123lorem', :password_confirmation => '123lorem')
    click_login

    click_link("Esqueceu sua senha?")
    fill_in 'user_email', :with => user.email
    click_button 'user_submit'

    sleep 2
    ActionMailer::Base.deliveries.should_not be_empty
  end
end

feature "with devise routes" do

  scenario "Try login with email that another provider" do
    visit new_user_session_path
    user_facebook = Factory.create(:user, :provider => 'facebook', :uid => '1234566',:email => 'lorem@lorem.com', :password => 'somepassword', :password_confirmation => 'somepassword')

    fill_in 'user_email', :with => user_facebook.email
    fill_in 'user_password', :with => user_facebook.password
    click_button 'user_submit'

    page.should have_no_css('#user')
    page.should have_css('.alert.wrapper')
  end

  scenario "Login with devise user" do
    visit new_user_session_path
    user = Factory.create(:user, :provider => 'devise',:email => 'lorem@lorem.com', :password => '123lorem', :password_confirmation => '123lorem')

    fill_in 'user_email', :with => user.email
    fill_in 'user_password', :with => user.password
    click_button 'user_submit'

    page.should have_css('.user')
    page.should have_link(I18n.t('layouts.header.account'))
  end

  scenario "Register new user using devise" do
    visit new_user_registration_path

    within ".new_registration" do
      fill_in "Nome", with: "Foo Bar"
      fill_in "Email", with: "foo@bar.com"
      fill_in "Senha", with: "foo!bar"
      fill_in "user_password_confirmation", with: "foo!bar"
      click_button "Efetuar cadastro"
    end
    verify_translations
    page.should have_css('.user')
  end

  scenario "Request new password" do
    ActionMailer::Base.deliveries = []
    ActionMailer::Base.deliveries.should be_empty

    user = Factory.create(:user, :provider => 'devise',:email => 'lorem@lorem.com', :password => '123lorem', :password_confirmation => '123lorem')
    visit new_user_password_path
    page.should have_css('h1', :text => I18n.t('passwords.new.title'))
    fill_in 'user_email', :with => user.email
    click_button 'user_submit'
    sleep 2

    ActionMailer::Base.deliveries.should_not be_empty
  end
end
