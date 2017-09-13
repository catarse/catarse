class MailMarketingList < ActiveRecord::Base
  has_many :mail_marketing_users
  validates :provider, :label, :list_id, presence: true
  validates :provider,  uniqueness: {scope: :label }
  validates :provider,  uniqueness: {scope: :list_id }
end
