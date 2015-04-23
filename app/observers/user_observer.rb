class UserObserver < ActiveRecord::Observer
  observe :user

  def before_validation(user)
    user.password = SecureRandom.hex(4) unless user.password || user.persisted?
  end

  def after_create(user)
    user.notify(:new_user_registration)
  end

  def before_save(user)
    user.fix_twitter_user
    user.fix_facebook_link
    user.nullify_permalink
  end
end
