class MailMarketingUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :mail_marketing_list

  after_destroy do
    SendgridSyncWorker.perform_async(user_id, mail_marketing_list_id)
  end
end
