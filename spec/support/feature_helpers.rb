module FeatureHelpers
  def login(via = :visit)
    if via == :visit
      visit new_user_session_path
    else
      within "#header" do
        click_link 'login'
      end
    end

    within ".login-box" do
      fill_in 'user_email', with: current_user.email
      fill_in 'user_password', with: 'test123'
      find('.button.success').click
    end
  end

  def current_user
    @user ||= FactoryGirl.create(:user, password: 'test123', password_confirmation: 'test123')
  end
end

RSpec.configure do |config|
  config.include FeatureHelpers, type: :feature
end
