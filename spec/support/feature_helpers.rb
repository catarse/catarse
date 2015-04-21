module FeatureHelpers
  TIME_TO_SLEEP = 4
  
  def login
    visit new_user_session_path

    within ".w-form" do
      fill_in 'user_email', with: current_user.email
      fill_in 'user_password', with: 'test123'
      find('.btn.btn-medium').click
    end
  end

  def current_user
    FactoryGirl.create(:country)
    @user ||= FactoryGirl.create(:user, password: 'test123', password_confirmation: 'test123')
  end
end

RSpec.configure do |config|
  config.include FeatureHelpers, type: :feature
end
