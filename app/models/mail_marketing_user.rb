class MailMarketingUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :mail_marketing_list

  scope :unsynced, -> { where(last_sync_at: nil)}
  validates :mail_marketing_list_id, uniqueness: { scope: :user_id }

  after_destroy do
    SendgridSyncWorker.perform_async(user_id, mail_marketing_list_id)
  end
end
