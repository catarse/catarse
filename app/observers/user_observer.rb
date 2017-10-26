# frozen_string_literal: true

class UserObserver < ActiveRecord::Observer
  observe :user

  def before_validation(user)
    user.password = SecureRandom.hex(4) unless user.password || user.persisted?
  end

  def after_create(user)
    user.notify(:new_user_registration)
    if user.newsletter
      newsletter_list = MailMarketingList.find_by_list_id CatarseSettings[:sendgrid_newsletter_list_id]
      user.mail_marketing_users.create(
        mail_marketing_list_id: newsletter_list.id
      )
      SendgridSyncWorker.perform_async(user.id)
    end
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

    if user.mail_marketing_users.unsynced.present?
      SendgridSyncWorker.perform_async(user.id)
    end

    user.index_on_common
  end
end
