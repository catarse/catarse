require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')
feature "Logout Feature" do
  scenario "Given I'm logged in, I must be able to logout" do
    fake_login
    page.should have_link(user.display_name)
    click_link user.display_name
    click_link "Sair"
    page.should have_no_link(user.display_name)
    verify_translations
  end
end
