module FeatureHelpers
  def current_user
    @user ||= User.where(uid: 'fake_login').first
  end
end

RSpec.configure do |config|
  config.include FeatureHelpers, type: :feature
end
