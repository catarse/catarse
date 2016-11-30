class UserObserver < ActiveRecord::Observer
  observe :user

  def before_validation(user)
    user.password = SecureRandom.hex(4) unless user.password || user.persisted?
  end

  def after_create(user)
    user.notify(:new_user_registration)
    SendgridSyncWorker.perform_async(user.id) if user.newsletter
  end

  def before_save(user)
    user.fix_twitter_user
    user.fix_facebook_link
    user.nullify_permalink
  end

  def after_save(user)
    if user.try(:facebook_link_changed?) && user.facebook_link.to_s != ''
      FbPageCollectorWorker.perform_async(user.id)
    end

    if user.newsletter_changed?
      SendgridSyncWorker.perform_async(user.id)
    end
  end
end
