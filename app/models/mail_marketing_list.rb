class MailMarketingList < ActiveRecord::Base
  validates :provider, :label, :list_id, presence: true
  validates :provider, :label, uniqueness: true
  validates :provider, :list_id, uniqueness: true
end
