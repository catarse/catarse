require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Login Feature" do

  scenario "I'm new to the platform and I want to signup with a supported provider" do
    click_login
    page.should have_link('Google')
    page.should have_no_link('Github')

    fake_login
    verify_translations
    page.should have_css('.user')
    page.should have_link(I18n.t('layouts.header.account'))
  end

  scenario "After insertion of a new provider it should appear in the login options" do
    Factory(:oauth_provider)
    click_login
    page.should have_link('Google')
    page.should have_link('Github')
  end

end
