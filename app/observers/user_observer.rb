class UserObserver < ActiveRecord::Observer
  observe :user

  def before_save(user)
    user.fix_twitter_user
  end
end
