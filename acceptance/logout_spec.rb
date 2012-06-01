require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Logout Feature" do

  scenario "Given I'm logged in, I must be able to logout" do

    fake_login
    page.should have_link(I18n.t('layouts.header.account'))
    click_link I18n.t('layouts.header.account')
    click_link "Sair"
    page.should have_no_link(I18n.t('layouts.header.account'))
    verify_translations

  end

end
